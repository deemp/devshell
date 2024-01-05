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
        assert assertMsg (cmd.name != null || cmd.package != null) "${commandsMessage} some command is missing both a `name` and a `package` attribute.";
        let
          name = resolveName cmd;

          help =
            if cmd.help == null then
              cmd.package.meta.description or ""
            else
              cmd.help;
        in
        cmd // {
          inherit help;
          name = if name != null && cmd.package == null && strings.hasInfix " " name then "'${name}'" else name;
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

  mkCommandMenu = configs: flatOptionsType.merge [ ] [
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
                commands = [ commandMenu ] ++ config.commands;
                commandMenu = mkCommandMenu commands;
              in
              [ commandMenu ] ++ configs
            )
          }
          DEVSHELL_MENU
        '';
      };
    }
  ];
}
