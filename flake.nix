{
  description = "Standalone firefox flake for non-nix systems";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-22.05";
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
      in
      {
        packages.standalone-firefox = pkgs.callPackage ./firefox.nix {
          inherit pkgs;
          arch = "linux-x86_64";
        };
      });
}
