{
  description = "Nix flake that provides the Salesforce CLI.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
  }:
    flake-parts.lib.mkFlake {inherit inputs;} ({system, ...}: {
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      perSystem = {
        pkgs,
        self',
        ...
      }: let
        sfPackage = import ./package.nix {inherit pkgs;};
      in {
        formatter = pkgs.alejandra;
        packages.default = sfPackage;
        apps.default = {
          type = "app";
          program = self'.packages.default.passthru.exePath;
        };
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [nodejs yarn prefetch-yarn-deps fixup-yarn-lock];
        };
      };
    });
}
