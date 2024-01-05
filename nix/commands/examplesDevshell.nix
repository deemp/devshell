{ pkgs, devshell }: {
  nested = devshell.mkShell {
    devshell.name = "nested-commands-example";
    commands = (import ./examples.nix { inherit pkgs; }).nested;
  };
  flat = devshell.mkShell {
    devshell.name = "flat-commands-example";
    commands = (import ./examples.nix { inherit pkgs; }).flat;
  };
}
