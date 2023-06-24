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
          nodejs = pkgs.nodejs_18;
        });
      # TODO can I fix this with a derivation?
      sfdx = nodePackages.sfdx-cli // {
        name = "sfdx";
        pname = "sfdx";
      };
      sf = nodePackages."@salesforce/cli" // {
        name = "sf";
        pname = "sf";
      };
    in rec {
      packages.sfdx = sfdx;
      packages.sf = sf;
      packages.default = packages.sf;
      devShells.default =
        pkgs.mkShell {buildInputs = [pkgs.node2nix];};
    });
}
