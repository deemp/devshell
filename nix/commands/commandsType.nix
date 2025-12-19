{
  system ? builtins.currentSystem,
  pkgs ? import ../nixpkgs.nix { inherit system; },
  options ? { },
}:
let
  inherit (builtins)
    concatStringsSep
    hasAttr
    head
    isAttrs
    isList
    isString
    ;

  inherit (pkgs.lib)
    attrByPath
    collect
    flatten
    isDerivation
    last
    mapAttrsRecursiveCond
    mapAttrsToList
    parseDrvName
    pipe
    ;

  inherit (pkgs.lib.options) unknownModule;

  inherit (import ./types.nix { inherit pkgs options; })
    commandsFlatType
    commandsNestedType
    resolveKey
    strOrPackage
    ;

  extractHelp = arg: if isList arg then head arg else null;

  # Fallback to the package pname if the name is unset
  resolveName =
    cmd:
    if cmd.name == null then cmd.package.pname or (parseDrvName cmd.package.name).name else cmd.name;

  flattenNonAttrsOrElse =
    config: alternative:
    if !(isAttrs config) || isDerivation config then
      let
        value = pipe config [
          (x: if isList x then last x else x)
          (x: if strOrPackage.check x then resolveKey x else x)
        ];
        help = extractHelp config;
      in
      [
        {
          name = resolveName value;
          inherit help;
          ${if isString value then "command" else "package"} = value;
        }
      ]
    else
      alternative;

  mergeCommandsFlat =
    {
      arg,
      loc ? [ ],
      file ? unknownModule,
    }:
    pipe arg [
      flatten
      (map (value: {
        inherit file;
        value = [ value ];
      }))
      (commandsFlatType.merge loc)
    ];

  normalizeCommandsFlat' = map (config: flattenNonAttrsOrElse config config);

  normalizeCommandsFlat = arg: mergeCommandsFlat { arg = normalizeCommandsFlat' arg; };

  highlyUnlikelyAttrName = "adjd-laso-msle-copq-pcod";

  collectLeaves =
    attrs:
    pipe attrs [
      (mapAttrsRecursiveCond (attrs: !(isDerivation attrs)) (
        path: value: {
          "${highlyUnlikelyAttrName}" = {
            inherit path;
            inherit value;
          };
        }
      ))
      (collect (hasAttr highlyUnlikelyAttrName))
      (map (x: x.${highlyUnlikelyAttrName}))
    ];

  normalizeCommandsNested' =
    arg:
    pipe arg [
      # typecheck and augment configs with missing attributes (if a config is an attrset)
      (
        x:
        commandsNestedType.merge
          [ ]
          [
            {
              file = unknownModule;
              value = x;
            }
          ]
      )
      (mapAttrsToList (
        category:
        map (
          config:
          (map (x: x // { inherit category; })) (
            (flattenNonAttrsOrElse config) (
              # a nestedOptionsType at this point has all attributes due to augmentation
              if config ? packages then
                let
                  inherit (config)
                    packages
                    commands
                    helps
                    prefixes
                    exposes
                    interpolates
                    ;

                  mkCommands =
                    forPackages:
                    pipe (collectLeaves (if forPackages then packages else commands)) [
                      (map (
                        leaf:
                        let
                          value = pipe leaf.value [
                            (x: if isList x then last x else x)
                            (x: if forPackages && strOrPackage.check x then resolveKey x else x)
                          ];

                          path = leaf.path;

                          name = concatStringsSep "." path;

                          help =
                            if isList leaf.value then
                              head leaf.value
                            else
                              attrByPath path (
                                if isDerivation value then value.meta.description or null else config.help or null
                              ) helps;

                          prefix = attrByPath path config.prefix prefixes;

                          expose = attrByPath path (if config.expose != null then config.expose else (!forPackages)) exposes;

                          interpolate = attrByPath path config.interpolate interpolates;
                        in
                        {
                          "${if forPackages then "package" else "command"}" = value;
                          inherit
                            name
                            prefix
                            help
                            category
                            expose
                            interpolate
                            ;
                        }
                      ))
                    ];
                in
                (mkCommands true) ++ (mkCommands false)
              else
                [ config ]
            )
          )
        )
      ))
    ];

  normalizeCommandsNested = arg: mergeCommandsFlat { arg = normalizeCommandsNested' arg; };
in
{
  inherit
    extractHelp
    resolveName
    flattenNonAttrsOrElse
    highlyUnlikelyAttrName
    collectLeaves
    mergeCommandsFlat
    normalizeCommandsFlat'
    normalizeCommandsFlat
    normalizeCommandsNested'
    normalizeCommandsNested
    ;
}
