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
  }: let
    linkMapping = {
      "aarch64-linux" = "https://developer.salesforce.com/media/salesforce-cli/sfdx/versions/sfdx-linux-arm-tar-gz.json";
      "aarch64-darwin" = "https://developer.salesforce.com/media/salesforce-cli/sfdx/versions/sfdx-arm64-pkg.json";
      "x86_64-darwin" = "https://developer.salesforce.com/media/salesforce-cli/sfdx/versions/sfdx-x64-pkg.json";
      "x86_64-linux" = "https://developer.salesforce.com/media/salesforce-cli/sfdx/versions/sfdx-linux-x64-tar-xz.json";
    };
  in
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      version = "7.207.3";
      isMac = nixpkgs.lib.hasInfix "darwin" system;
      isLinux = nixpkgs.lib.hasInfix "linux" system;

      json = builtins.fetchurl {
        url = linkMapping.${system};
        sha256 = "1d1gqfb41vc8sk0xw56vdrlgb2cz9l7rn72z6maa6z8fqhrm5xmh";
      };
      sfdx = pkgs.stdenv.mkDerivation {
        inherit version;
        name = "sfdx";
        pname = "sfdx";
        nativeBuildInputs = with pkgs; [xar];
        src =
          if isMac
          then
            pkgs.fetchurl {
              url = (builtins.fromJSON (builtins.readFile json)).${version};
              sha256 = "0jrlk1g60jfmim9925zrnhvrn1k9ic1y7c4ws5f7las99pfdj34g";
              postFetch = ''
                xar -xf $src
              '';
            }
          else
            fetchTarball {
              url = (builtins.fromJSON (builtins.readFile json)).${version};
              sha256 = "";
            };

        # src = pkgs.
      };
    in rec {
      packages.sfdx = sfdx;
      # packages.sf = sf;
      # packages.default = packages.sf;
      devShells.default =
        pkgs.mkShell {buildInputs = [pkgs.node2nix pkgs.alejandra];};
    });
}
