{
  description = "Standalone firefox flake for non-nix systems";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        standalone-firefox = pkgs.callPackage ./firefox.nix {
          inherit pkgs;
          nixpkgsSource = nixpkgs.outPath;
        };
      in {
        packages.standalone-firefox = standalone-firefox;
        defaultPackage = standalone-firefox;

      }) // {
        overlay = final: prev: let
          localFirefox = import ./firefox.nix {
            pkgs = prev;
            nixpkgsSource = nixpkgs.outPath;
          };
        in {
          standalone-firefox = localFirefox;
        };
      };
}
