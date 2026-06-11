{
  description = "Nix flake that provides the Salesforce CLI.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
      perSystem = {pkgs, ...}: {
        formatter = pkgs.alejandra;
        packages.default = import ./package.nix {inherit pkgs;};
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [nodejs yarn prefetch-yarn-deps fixup-yarn-lock];
        };
      };
    };
}
