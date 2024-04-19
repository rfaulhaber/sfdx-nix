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
        name = "salesforce-cli";
        version = "2.39.1";
        src = pkgs.fetchFromGitHub {
          owner = "salesforcecli";
          repo = "cli";
          rev = version;
          hash = "sha256-BQAL3SFI/GUj42urdRyTWbSeX3jrwXXejqpH6M4CXk8=";
        };
        offlineCache = pkgs.fetchYarnDeps {
          yarnLock = "${src}/yarn.lock";
          hash = "sha256-OkiphOEXpUhXp5Hh8Tn+62SvmbNwD4qGsIalp7vCpuk=";
        };
      in
        pkgs.stdenv.mkDerivation {
          inherit version src;
          pname = name;
          nativeBuildInputs = with pkgs; [nodejs yarn prefetch-yarn-deps];
          phases = ["unpackPhase" "configurePhase" "buildPhase" "installPhase" "distPhase"];

          configurePhase = ''
            export HOME=$PWD/yarn_home
            yarn config --offline set yarn-offline-mirror ${offlineCache}
          '';

          buildPhase = ''
            export HOME=$PWD/yarn_home
            export SF_HIDE_RELEASE_NOTES=true
            fixup-yarn-lock ./yarn.lock
            chmod -R +rw $PWD/scripts
            yarn --offline install --ignore-scripts
            chmod -R +rw $PWD/node_modules
            patchShebangs --build node_modules
            yarn --offline --production=true run build
          '';

          installPhase = ''
            mkdir $out
            mv node_modules $out/
            mv dist $out/
            mkdir -p $out/bin
            mv bin/run.js $out/bin/${name}
            # necessary for some runtime configuration
            cp ./package.json $out
            patchShebangs $out
          '';

          distPhase = ''
            mkdir -p $out/tarballs/
            yarn pack --offline --ignore-scripts --production=true --filename $out/tarballs/${name}/.tgz
          '';
        };
    in {
      packages.sf = sf;
      packages.default = sf;
      formatter = pkgs.alejandra;
      devShells.default =
        pkgs.mkShell {buildInputs = with pkgs; [nodejs yarn];};
    });
}
