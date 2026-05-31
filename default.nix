{
  pkgs ? import <nixpkgs> {},
  system ? pkgs.stdenv.hostPlatform.system,
}: let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  mkZen = name: entry: let
    variant = (builtins.fromJSON (builtins.readFile ./sources.json)).variants.${entry}.${system};
  in
    pkgs.callPackage ./package.nix {
      inherit name variant;
    };
in rec {
  beta-unwrapped = mkZen "beta" "beta";
  twilight-unwrapped = mkZen "twilight" "twilight";
  twilight-official-unwrapped = mkZen "twilight" "twilight-official";

  # wrapFirefox uses __structuredAttrs = true which breaks on Darwin's stdenv
  # with: "syntax error near unexpected token `('"
  # On Darwin the wrapper adds minimal value (no LD_LIBRARY_PATH, GTK, XDG)
  # so we expose the unwrapped package directly.
  beta =
    if isDarwin
    then beta-unwrapped
    else
      pkgs.wrapFirefox beta-unwrapped {
        icon = "zen-browser";
      };
  twilight =
    if isDarwin
    then twilight-unwrapped
    else pkgs.wrapFirefox twilight-unwrapped {};
  twilight-official =
    if isDarwin
    then twilight-official-unwrapped
    else
      pkgs.wrapFirefox twilight-official-unwrapped {
        icon = "zen-twilight";
      };

  default = beta;
}
