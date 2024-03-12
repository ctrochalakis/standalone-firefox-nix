{
  description = "Standalone firefox flake for non-nix systems";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
  inputs.utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, utils }:
    {
      nixosModule = {
        nixpkgs.overlays = [
          (final: prev: {
            standalone-firefox = self.packages."${final.stdenv.hostPlatform.system}".standalone-firefox;
          })
        ];
      };
    } // utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        firefoxPackage = pkgs.callPackage ./firefox.nix {
          inherit pkgs;
          arch = "linux-x86_64";
        };
      in
      {
        packages.standalone-firefox = firefoxPackage;
        packages.default = firefoxPackage;
      });
}
