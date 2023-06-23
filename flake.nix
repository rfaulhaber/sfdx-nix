{
  description = "Nix flake that provides sfdx-cli.";

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
      sfdx-cli =
        (pkgs.callPackage ./default.nix {
          inherit pkgs system;
          # NOTE: we have to use node 14 or less, otherwise this won't build!
          # I would like to fix this!
          nodejs = pkgs.nodejs_20;
        })
        .sfdx-cli;
    in rec {
      packages.sfdx-cli = sfdx-cli;
      packages.default = packages.sfdx-cli;
      devShells.default =
        pkgs.mkShell {buildInputs = [sfdx-cli pkgs.node2nix];};
    });
}
