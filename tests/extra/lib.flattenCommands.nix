{ pkgs, devshell, runTest }:
{
  simple =
    let
      commands = (import ../../nix/commands/examples.nix { inherit pkgs; }).nested;
      check = (import ../../nix/commands/lib.nix { inherit pkgs; }).normalizeCommandsNested commands == [
        {
          category = "category 1";
          command = null;
          expose = false;
          help = "[package] jq description";
          name = "nix run .#a.b.jq-1";
          package = pkgs.jq;
        }
        {
          category = "category 1";
          command = null;
          expose = false;
          help = "[package] yq description";
          name = "nix run .#a.b.yq-1";
          package = pkgs.yq-go;
        }
        {
          category = "category 1";
          command = null;
          expose = false;
          help = "Portable command-line YAML processor";
          name = "nix run .#a.b.yq-2";
          package = pkgs.yq-go;
        }
        {
          category = "category 1";
          command = null;
          expose = false;
          help = "a package manager for JavaScript";
          name = "nix run .#npm";
          package = pkgs.nodePackages.npm;
        }
        {
          category = "category 1";
          command = null;
          expose = true;
          help = "GNU Find Utilities, the basic directory searching utilities of the GNU operating system";
          name = "a.b.findutils";
          package = pkgs.findutils;
        }
        {
          category = "category 1";
          command = null;
          expose = false;
          help = "Command-line benchmarking tool";
          name = "a.b.hyperfine";
          package = pkgs.hyperfine;
        }
        {
          category = "category 1";
          command = "${pkgs.gawk}/bin/awk";
          expose = false;
          help = "[command] run awk";
          name = "a.b.awk";
          package = null;
        }
        {
          category = "category 1";
          command = "${pkgs.jq}/bin/jq";
          expose = false;
          help = "[command] run jq";
          name = "a.b.jq-2";
          package = null;
        }
        {
          category = "category 1";
          command = "printf \"hello\\n\"";
          expose = false;
          help = "[command] print \"hello\"";
          name = "command with spaces";
          package = null;
        }
        {
          category = "category 1";
          command = null;
          expose = true;
          help = null;
          name = pkgs.python3.name;
          package = pkgs.python3;
        }
        {
          category = "category 1";
          command = null;
          expose = true;
          help = "[package] vercel description";
          name = pkgs.nodePackages.vercel.name;
          package = pkgs.nodePackages.vercel;
        }
        {
          category = "category 1";
          command = null;
          expose = true;
          help = null;
          name = pkgs.nodePackages.yarn.name;
          package = pkgs.nodePackages.yarn;
        }
        {
          category = "category 1";
          command = null;
          expose = true;
          help = null;
          name = null;
          package = pkgs.gnugrep;
        }
        {
          category = "category-2";
          command = null;
          expose = true;
          help = null;
          name = null;
          package = pkgs.go;
        }
        {
          category = "category-2";
          command = null;
          expose = true;
          help = "[package] run hello ";
          name = pkgs.hello.name;
          package = pkgs.hello;
        }
        {
          category = "category-2";
          command = null;
          expose = true;
          help = null;
          name = pkgs.nixpkgs-fmt.name;
          package = pkgs.nixpkgs-fmt;
        }
      ];
    in
    runTest "simple" { } ''
      ${
        if check
        then ''printf "OK"''
        else ''printf "Not OK"; exit 1''
      }
    '';
}
