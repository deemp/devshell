{ system ? builtins.currentSystem
, pkgs ? import ../nixpkgs.nix { inherit system; }
, lib ? pkgs.lib
}:
with lib;
with builtins;
rec {
  # find a package corresponding to the string
  resolveKey = arg:
    if isString arg && lib.strings.sanitizeDerivationName arg == arg then
      attrByPath (splitString "\." arg) null pkgs
    else if isDerivation arg then
      arg
    else null;

  strOrPackage = types.coercedTo types.str resolveKey types.package;

  maxDepth = 100;

  attrsOfNested = elemType:
    let elems = genList (x: null) maxDepth; in
    foldl
      (t: _: types.attrsOf (types.either elemType t) // {
        description = "(nested (max depth is ${toString maxDepth}) attribute set of ${
          types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
        })";
      })
      elemType
      elems;

  list2Of = t1: t2: mkOptionType {
    name = "list2Of";
    description = "list with two elements of types: [ ${
      concatMapStringsSep " " (types.optionDescriptionPhrase (class: class == "noun" || class == "composite")) [ t1 t2 ]
    } ]";
    check = x: isList x && length x == 2 && t1.check (head x) && t2.check (last x);
    merge = mergeOneOption;
  };

  flatOptions = import ./flatOptions.nix { inherit lib strOrPackage; };

  mkAttrsToString = str: { __toString = _: str; };

  flatOptionsType =
    let submodule = types.submodule { options = flatOptions; }; in
    submodule // rec {
      name = "flatOptions";
      description = name;
      getSubOptions = prefix: (mapAttrs
        (name_: value: value // {
          loc = prefix ++ [
            name_
            (mkAttrsToString " (${name})")
          ];
          declarations = [ "${toString ../..}/nix/commands/flatOptions.nix" ];
        })
        (submodule.getSubOptions prefix));
    };

  pairHelpPackageType = list2Of types.str strOrPackage;

  pairHelpCommandType = list2Of types.str types.str;

  nestedOptions = import ./nestedOptions.nix { inherit pkgs strOrPackage attrsOfNested pairHelpPackageType pairHelpCommandType flatOptionsType maxDepth; };

  nestedOptionsType =
    let submodule = types.submodule { options = nestedOptions; }; in
    submodule // rec {
      name = "nestedOptions";
      description = name;
      check = x: (x?prefixes || x?packages || x?commands || x?helps || x?exposes) && submodule.check x;
      getSubOptions = prefix: (mapAttrs
        (name_: value: value // {
          loc = prefix ++ [
            name_
            (mkAttrsToString " (${name})")
          ];
          declarations = [ "${toString ../..}/nix/commands/nestedOptions.nix" ];
        })
        (submodule.getSubOptions prefix));
    };

  nestedConfigType =
    (
      types.oneOf [
        strOrPackage
        pairHelpPackageType
        pairHelpCommandType
        nestedOptionsType
        flatOptionsType
      ]
    )
    // {
      getSubOptions = prefix: {
        "${flatOptionsType.name}" = flatOptionsType.getSubOptions prefix;
        "${nestedOptionsType.name}" = nestedOptionsType.getSubOptions prefix;
      };
    }
  ;

  flatConfigType =
    (
      types.oneOf [
        strOrPackage
        pairHelpPackageType
        pairHelpCommandType
        flatOptionsType
      ]
    ) // {
      getSubOptions = prefix: {
        flat = flatOptionsType.getSubOptions prefix;
      };
    }
  ;

  commandsFlatType = types.listOf flatConfigType // {
    name = "commandsFlat";
    getSubOptions = prefix: {
      fakeOption = (
        mkOption
          {
            type = flatConfigType;
            description = ''
              A config for a command when the `commands` option is a list ("flat").
            '';
            example = literalExpression ''
              [
                {
                  category = "scripts";
                  package = "black";
                }
                [ "[package] print hello" "hello" ]
                "nodePackages.yarn"
              ]
            '';
          }
      ) // {
        loc = prefix ++ [ "*" ];
        declarations = [ "${toString ../..}/nix/commands/types.nix" ];
      };
    };
  };

  commandsNestedType = types.attrsOf (types.listOf nestedConfigType) // {
    name = "commandsNested";
    getSubOptions = prefix: {
      fakeOption = (
        mkOption {
          type = nestedConfigType;
          description = ''
            A config for command(s) when the `commands` option is an attrset ("nested").
          '';
          example = literalExpression ''
            {
              category = [
                {
                  packages.grep = pkgs.gnugrep;
                }
                pkgs.python3
                [ "[package] vercel description" "nodePackages.vercel" ]
                "nodePackages.yarn"
              ];
            }
          '';
        }
      ) // {
        loc = prefix ++ [ "<name>" "*" ];
        declarations = [ "${toString ../..}/nix/commands/types.nix" ];
      };
    };
  };
}
