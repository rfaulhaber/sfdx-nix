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
      nodePackages =
        (pkgs.callPackage ./default.nix {
          inherit pkgs system;
          nodejs = pkgs.nodejs_20;
        });
      sfdx = pkgs.stdenv.mkDerivation {
        name = "sfdx";
        pname = "sfdx";
        src = nodePackages.sfdx-cli.src;
        version = nodePackages.sfdx-cli.version;
      };
      sf = pkgs.stdenv.mkDerivation {
        name = "sf";
        pname = "sf";
        src = nodePackages."@salesforce/cli".src;
        version = nodePackages."@salesforce/cli".version;
      };
    in rec {
      packages.sfdx = sfdx;
      packages.sf = sf;
      # packages.default = packages.sf;
      devShells.default =
        pkgs.mkShell {buildInputs = [sfdx sf pkgs.node2nix];};
    });
}
