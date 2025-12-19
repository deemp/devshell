{
  lib,
  config,
  pkgs,
  options,
  ...
}:
let
  inherit (import ../nix/commands/lib.nix { inherit pkgs options config; })
    commandsFlatType
    commandsNestedType
    normalizeCommandsFlat
    normalizeCommandsNested
    devshellMenuCommandName
    commandToPackage
    commandsToMenu
    ;
in
{
  options.commands = lib.mkOption {
    type = commandsFlatType;
    default = [ ];
    description = ''
      Add commands to the environment.
    '';
    example = lib.literalExpression ''
      [
        {
          help = "print hello";
          name = "hello";
          command = "echo hello";
        }
        {
          package = "nixfmt";
          category = "formatter";
        }
      ]
    '';
  };

  options.commandGroups = lib.mkOption {
    type = commandsNestedType;
    default = { };
    description = ''
      Add commands to the environment.
    '';
    example = lib.literalExpression ''
      {
        packages = [
          "diffutils"
          "goreleaser"
        ];
        scripts = [
          {
            prefix = "nix run .#";
            inherit packages;
          }
          {
            name = "nix fmt";
            help = "format Nix files";
          }
        ];
        utilites = [
          [ "GitHub utility" "hub" ]
          [ "golang linter" "golangci-lint" ]
        ];
      }
    '';
  };

  config.commands = [
    {
      help = "prints this menu";
      name = devshellMenuCommandName;
      command = commandsToMenu config.devshell.menu config.devshell.commands;
    }
  ];

  config.devshell.commands =
    normalizeCommandsFlat config.commands ++ normalizeCommandsNested config.commandGroups;

  # Add the commands to the devshell packages. Either as wrapper scripts, or
  # the whole package.
  config.devshell.packages = lib.filter (x: x != null) (
    map commandToPackage config.devshell.commands
  );

  # config.devshell.motd = "$(motd)";
}
