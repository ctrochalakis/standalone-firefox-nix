{ pkgs, nixpkgsSource, locale ? "en-US", arch ? "linux-x86_64" }:
let
  inherit (pkgs) lib;

  generated = import
    ("${nixpkgsSource}/pkgs/applications/networking/browsers/firefox-bin/release_sources.nix");
  inherit (generated) version sources;

  sourceMatches = locale: source:
    source.locale == locale && source.arch == arch;
  defaultSource = lib.findFirst (sourceMatches "en-US") { } sources;
  source = lib.findFirst (sourceMatches locale) defaultSource sources;

  pname = "standalone-firefox";

in pkgs.stdenv.mkDerivation {
  inherit pname version;

  src = pkgs.fetchurl { inherit (source) url sha256; };

  patchPhase = ''
    # Don't download updates from Mozilla directly
    echo 'pref("app.update.auto", "false");' >> defaults/pref/channel-prefs.js
    echo 'pref("browser.fullscreen.autohide", "false");' >> defaults/pref/channel-prefs.js
  '';

  installPhase = ''
    mkdir -p "$prefix/usr/lib/firefox-bin-${version}"
    cp -r * "$prefix/usr/lib/firefox-bin-${version}"

    mkdir -p "$out/bin"
    ln -s "$prefix/usr/lib/firefox-bin-${version}/firefox" "$out/bin/"

    # wrapFirefox expects "$out/lib" instead of "$out/usr/lib"
    ln -s "$out/usr/lib" "$out/lib"
  '';

  meta = {
    description = "Upstream firefox package for non Nix environments";
    mainProgram = "firefox";
  };
}
