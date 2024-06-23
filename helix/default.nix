{ pkgs, ... }:

{
  config = (import ./config.nix { inherit pkgs; }).config;

  extraPackages = with pkgs; [
    hello
    rust-analyzer
  ];
}
