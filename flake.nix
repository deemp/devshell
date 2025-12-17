{
  description = "devshell";
  # To update all inputs:
  # nix flake update
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "riscv64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      eachSystem =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f rec {
            inherit system;
            pkgs = nixpkgs.legacyPackages.${system};
            devshell = import ./. { nixpkgs = pkgs; };
          }
        );
    in
    rec {
      packages = eachSystem (
        {
          pkgs,
          system,
          devshell,
        }:
        {
          docs = pkgs.writeShellApplication {
            name = "docs";
            meta.description = ''Run mdBook server at http://localhost:3000'';
            runtimeInputs = [ pkgs.mdbook ];
            text = ''
              cd docs
              cp ${devshell.modules-docs.markdown} src/modules_schema.md
              mdbook serve
            '';
          };
          bench = pkgs.writeShellApplication {
            name = "benchmark";
            meta.description = ''Run benchmark'';
            runtimeInputs = [ pkgs.hyperfine ];
            text = ''
              cd benchmark
              hyperfine -w 3 \
                'nix-instantiate ../shell.nix' \
                'nix-instantiate ./devshell-nix.nix' \
                'nix-instantiate ./devshell-toml.nix' \
                'nix-instantiate ./nixpkgs-mkshell.nix'
            '';
          };
          # expose devshell as an executable package
          default = self.devShells.${system}.default;
        }
      );

      devShells = eachSystem (
        { devshell, ... }:
        {
          default = devshell.mkShell {
            bash.extra = ''
              export MDBOOK_SERVER_ADDRESS="http://localhost:3000"
            '';
            commands = {
              packages = [
                "diffutils" # used by golangci-lint
                "goreleaser"
              ];
              scripts = [
                {
                  prefix = "nix run .#";
                  inherit packages;
                  helps.docs = ''Run mdBook server at "$MDBOOK_SERVER_ADDRESS"'';
                  interpolates.docs = true;
                }
                {
                  name = "nix fmt";
                  help = "format Nix files";
                }
              ];
              utilites = [
                [ "GitHub utility" "gitAndTools.hub" ]
                [ "golang linter" "golangci-lint" ]
              ];
            };
          };
          toml = devshell.fromTOML ./devshell.toml;
        }
      );

      legacyPackages = eachSystem (
        { system, pkgs, ... }:
        import self {
          inherit system;
          inputs = null;
          nixpkgs = pkgs;
        }
      );

        apps.default = devShells.default.flakeApp;

        checks = eachSystem ({pkgs, ...}:
          with pkgs.lib;
          pipe { } [
            (x:
              x // (import ./tests { inherit pkgs; })
                // devShells
                // { inherit (devshell.modules-docs) markdown; }
            )
            (collect isDerivation)
            (map (x: { name = x.name or x.pname; value = x; }))
            listToAttrs
          ]
        );

        formatter = eachSystem ({ pkgs, ... }: pkgs.nixfmt);

      # Import this overlay into your instance of nixpkgs
      overlays.default = import ./overlay.nix;

      templates = rec {
        toml = {
          path = ./templates/toml;
          description = "nix flake new my-project -t github:numtide/devshell";
        };
        flake-parts = {
          path = ./templates/flake-parts;
          description = "nix flake new my-project -t github:numtide/devshell#flake-parts";
        };
        default = toml;
      };

      lib.importTOML = import ./nix/importTOML.nix;

      flakeModule = ./flake-module.nix;
    };
}
