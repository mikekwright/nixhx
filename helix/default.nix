{ inputs, system, ... }:

rec
{
  configPkgs = (import ./config.nix { inherit inputs system; });

  overlays = [(self: super: {
    helix = super.helix.overrideAttrs (oldAttrs: rec {
      postInstall = oldAttrs.postInstall + ''
        mv $out/bin/hx $out/bin/hx-raw
      '';
    });
  })];
}
