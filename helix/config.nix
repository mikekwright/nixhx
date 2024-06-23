{ pkgs, ... }:

let
  helixConfig = pkgs.writeTextDir "config/config.toml" ''
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

    [editor.lsp]
    enable = true
  '';
in
{
  config = helixConfig;
}

