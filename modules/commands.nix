{ lib, config, pkgs, ... }:
with lib;
let
  inherit (import ../nix/commands/lib.nix { inherit pkgs; })
    commandsType
    commandToPackage
    mkCommandMenu
    ;
in
{
  options.commands = mkOption {
    type = commandsType;
    default = [ ];
    description = ''
      Add commands to the environment.
    '';
    example = literalExpression ''
      {
        "scripts" = [
          {
            commands.hello = [ "print hello" "echo hello" ];
            packages.awk = "gawk"
          }
          "yq-go"
          pkgs.jq
        ];
        "formatter" = [
          "nixpkgs-fmt"
        ];
      }
    '';
  };

  # Add the commands to the devshell packages. Either as wrapper scripts, or
  # the whole package.
  config.devshell.packages =
    builtins.filter
      (x: x != null)
      (map commandToPackage ([ (mkCommandMenu config.commands) ] ++ config.commands));

  # config.devshell.motd = "$(motd)";
}
