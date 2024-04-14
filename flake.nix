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
          nativeBuildInputs = with pkgs; [nodejs yarn prefetch-yarn-deps];
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
            yarn --offline run build
          '';

          installPhase = ''
            mkdir $out
            mv node_modules $out/
            mv dist $out/
            mkdir -p $out/bin
            mv bin/run.js $out/bin/sf
            patchShebangs $out
'';
        };
    in rec {
      packages.sf = sf;
      packages.default = packages.sf;
      formatter = pkgs.alejandra;
      devShells.default =
        pkgs.mkShell {buildInputs = with pkgs; [node2nix nodejs_21];};
    });
}
