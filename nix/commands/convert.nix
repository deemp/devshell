{ system ? builtins.currentSystem
, pkgs ? import ../nixpkgs.nix { inherit system; }
, lib ? pkgs.lib
}:
with lib;
let
  inherit (import ./lib.nix { inherit pkgs; })
    resolveName
    flatOptionsType
    unknownFileName
    ;
in
rec {
  ansi = import ../ansi.nix;

  writeDefaultShellScript = import ../writeDefaultShellScript.nix {
    inherit (pkgs) lib writeTextFile bash;
  };

  pad = str: num:
    if num > 0 then
      pad "${str} " (num - 1)
    else
      str;

  # Fill in default options for a command.
  commandToPackage = cmd:
    if
      (cmd.name != devshellMenuCommandName && cmd.command == null)
      && cmd.package == null
    then null
    else
      assert assertMsg (cmd.command == null || cmd.name != cmd.command) "${commandsMessage} ${toString cmd.name} cannot be set to both the `name` and the `command` attributes. Did you mean to use the `package` attribute?";
      assert assertMsg (cmd.package != null || (cmd.command != null && cmd.command != "")) "${commandsMessage} ${resolveName cmd} expected either a command or package attribute.";
      if cmd.package == null
      then
        writeDefaultShellScript
          {
            name = cmd.name;
            text = cmd.command;
            binPrefix = true;
          }
      else if !cmd.expose
      then null
      else cmd.package;

  commandsToMenu = cmds:
    let
      cleanName = { name, package, ... }@cmd:
        if
          cmd.package == null && (cmd.name != devshellMenuCommandName && cmd.command == null)
          && (cmd.prefix != "" || (cmd.name != null && cmd.name != ""))
          && cmd.help != null
        then
          cmd // {
            name = "${
                if cmd.prefix != null then cmd.prefix else ""
              }${
                if cmd.name != null then cmd.name else ""
              }";
          }
        else
          assert assertMsg (cmd.name != null || cmd.package != null) "${commandsMessage} some command is missing both a `name` and a `package` attribute.";
          let
            name = pipe cmd [
              resolveName
              (x: if x != null && strings.hasInfix " " x then "'${x}'" else x)
              (x: "${cmd.prefix}${x}")
            ];

            help =
              if cmd.help == null then
                cmd.package.meta.description or ""
              else
                cmd.help;
          in
          cmd // {
            inherit name help;
          };

      commands = map cleanName cmds;

      commandLengths =
        map ({ name, ... }: builtins.stringLength name) commands;

      maxCommandLength =
        builtins.foldl'
          (max: v: if v > max then v else max)
          0
          commandLengths
      ;

      commandCategories = unique (
        (zipAttrsWithNames [ "category" ] (_: vs: vs) commands).category
      );

      commandByCategoriesSorted =
        builtins.attrValues (genAttrs
          commandCategories
          (category: nameValuePair category (builtins.sort
            (a: b: a.name < b.name)
            (builtins.filter (x: x.category == category) commands)
          ))
        );

      opCat = kv:
        let
          category = kv.name;
          cmd = kv.value;
          opCmd = { name, help, ... }:
            let
              len = maxCommandLength - (builtins.stringLength name);
            in
            if help == null || help == "" then
              "  ${name}"
            else
              "  ${pad name len} - ${help}";
        in
        "\n${ansi.bold}[${category}]${ansi.reset}\n\n" + builtins.concatStringsSep "\n" (map opCmd cmd);
    in
    builtins.concatStringsSep "\n" (map opCat commandByCategoriesSorted) + "\n";

  devshellMenuCommandName = "menu";

  mkDevshellMenuCommand = commands: flatOptionsType.merge [ ] [
    {
      file = unknownFileName;
      value = {
        help = "prints this menu";
        name = devshellMenuCommandName;
        command = ''
          cat <<'DEVSHELL_MENU'
          ${commandsToMenu
            (
              let
                commands_ = [ commandMenu ] ++ commands;
                commandMenu = mkDevshellMenuCommand commands_;
              in
              commands_
            )
          }
          DEVSHELL_MENU
        '';
      };
    }
  ];
}
