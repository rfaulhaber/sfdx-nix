{
  description = "Nix flake that provides sfdx.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      sfdx =
        (pkgs.callPackage ./default.nix {
          inherit pkgs system;
          nodejs = pkgs.nodejs_20;
        })
        .sfdx-cli;
    in rec {
      packages.sfdx = sfdx;
      packages.default = packages.sfdx;
      devShells.default =
        pkgs.mkShell {buildInputs = [sfdx pkgs.node2nix];};
    });
}
