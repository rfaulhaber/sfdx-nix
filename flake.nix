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
      pkgs = import nixpkgs {
        inherit system;
      };

      sf = let
        name = "sf";
        version = "2.38.0";
        src = pkgs.fetchFromGitHub {
          owner = "salesforcecli";
          repo = "cli";
          rev = version;
          hash = "sha256-D6RIEoZhh9LgbNyi88UZ8cjgnPJRjv7SxczgvCSQtYA=";
        };
        offlineCache = pkgs.fetchYarnDeps {
          yarnLock = src + "/yarn.lock";
          hash = "sha256-+2s9eGVyGlrGlmbPjNdGnSYf4IHzRCIkKZCXXj4tygI=";
        };
      in
        pkgs.stdenv.mkDerivation {
          inherit version src;
          pname = name;
          nativeBuildInputs = with pkgs; [nodejs_21 yarn fixup_yarn_lock prefetch-yarn-deps];
          configurePhase = ''
            export HOME=$PWD/yarn_home
            yarn config --offline set yarn-offline-mirror ${offlineCache}
          '';
          buildPhase = ''
            export HOME=$PWD/yarn_home
            fixup-yarn-lock ./yarn.lock
            chmod -R +rw $PWD/scripts
            yarn --offline  install
            chmod -R +rw $PWD/node_modules
            $PWD/node_modules/.bin/sf-install
          '';
        };
      #         pkgs.mkYarnPackage rec {
      #           inherit version;
      #           pname = name;
      #           src = pkgs.fetchFromGitHub {
      #             owner = "salesforcecli";
      #             repo = "cli";
      #             rev = version;
      #             hash = "sha256-D6RIEoZhh9LgbNyi88UZ8cjgnPJRjv7SxczgvCSQtYA=";
      #           };
      #           offlineCache = pkgs.fetchYarnDeps {
      #             yarnLock = src + "/yarn.lock";
      #             hash = "sha256-+2s9eGVyGlrGlmbPjNdGnSYf4IHzRCIkKZCXXj4tygI=";
      #           };
      #           nativeBuildInputs = with pkgs; [nodejs_21 yarn fixup_yarn_lock prefetch-yarn-deps];
      #           ignoreScripts = false;
      #           yarnFlags = [ "--production=false" ];
      #           # pkgConfig."@salesforce/cli".ignoreScripts = false;
      #           pkgConfig."@salesforce/cli".postInstall = ''
      #             echo "hello postinstall"
      #             echo "yarn bin: $(yarn bin)"
      #             export NODE_ENV="dev";
      #             yarn --offline --frozen-lockfile --ignore-scripts --production=true install
      #             export PATH=$PATH:$(yarn --offline bin)
      #             cp -r ${src}/scripts .
      #             ls ./node_modules/@salesforce
      #             yarn --offline --frozen-lockfile build
      # '';
      # };
    in rec {
      packages.sf = sf;
      packages.default = packages.sf;
      formatter = pkgs.alejandra;
      devShells.default =
        pkgs.mkShell {buildInputs = with pkgs; [node2nix nodejs_21];};
    });
}
