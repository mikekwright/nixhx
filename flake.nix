{
  description = "A Helix flake to try out helix as an editor";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = {
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = {
        pkgs,
        system,
        ...
      }: let
      helixSetup = (import ./helix { inherit inputs system pkgs; });
      helixScript = (pkgs.writeShellApplication {
        name = "hx";
        runtimeInputs = helixSetup.extraPackages;
        text = ''
          ls ${helixSetup.config}/config
          ${pkgs.helix}/bin/hx -c ${helixSetup.config}/config/config.toml "$@"
        '';
      });
      in rec {
        packages = with pkgs; {
          default = helixScript;
        };
      };
    };
}
