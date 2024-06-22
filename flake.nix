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
      originalHelix = pkgs.helix;

      overriddenHelix = originalHelix.overrideAttrs (oldAttrs: {
        name = "helix-overridden";

        buildCommand = ''
          set -euo pipefail

          ${
            # Copy original files, for each split-output (`out`, `dev` etc.).
            # E.g. `${package.dev}` to `$dev`, and so on. If none, just "out".
            # Symlink all files from the original package to here (`cp -rs`),
            # to save disk space.
            # We could alternatiively also copy (`cp -a --no-preserve=mode`).
            pkgs.lib.concatStringsSep "\n"
              (map
                (outputName:
                  ''
                    echo "Copying output ${outputName}"
                    set -x
                    cp -rs --no-preserve=mode "${originalHelix.${outputName}}" "''$${outputName}"
                    set +x
                  ''
                )
                (oldAttrs.outputs or ["out"])
              )
          }

          mv "$out/bin/hx" "$out/bin/hx-original"
        '';
      });

      myHelix = (pkgs.writeShellApplication {
        name = "hx";
        #runtimeInputs = [ pkgs.helix ];
        text = ''
          ${overriddenHelix}/bin/hx-original --help
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
