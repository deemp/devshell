{ system ? builtins.currentSystem
, pkgs ? import ./nixpkgs { inherit system; }
, lib ? pkgs.lib
}: (import ./commands/lib.nix { inherit pkgs; }).strOrPackage
