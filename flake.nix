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
      helixConfig = pkgs.writeText "helix-config.toml" ''
        theme = "onedark"

        [editor]
        line-number = "relative"
        mouse = false

        [editor.cursor-shape]
        insert = "bar"
        normal = "block"
        select = "underline"

        [editor.file-picker]
        hidden = false
      '';

      myHelix = (pkgs.writeShellApplication {
        name = "hx";
        text = ''
          ls ${helixConfig}
          ${pkgs.helix}/bin/hx -c ${helixConfig}
        '';
      });
      in rec {
        #results = (import ./helix { inherit inputs system; });

        #_module.args.pkgs = import inputs.nixpkgs {
        #  inherit system;
        #  overlays = results.overlays; # (import ./helix { inherit inputs system; }).overlays; 
        #};

        packages = with pkgs; {
          # Lets you run `nix run .` to start nixvim
          default = myHelix;
        };
      };
    };
}
