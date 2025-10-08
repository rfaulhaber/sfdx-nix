{pkgs}: let
  name = "salesforce-cli";
  versions = builtins.fromJSON (builtins.readFile ./versions.json);
  version = versions.cliVersion;
  src = pkgs.fetchFromGitHub {
    owner = "salesforcecli";
    repo = "cli";
    rev = version;
    hash = versions.cliHash;
  };
  offlineCache = pkgs.fetchYarnDeps {
    yarnLock = "${src}/yarn.lock";
    hash = versions.yarnHash;
  };
in
  pkgs.stdenv.mkDerivation (finalAttrs: {
    inherit version src;
    pname = name;
    nativeBuildInputs = with pkgs; [nodejs yarn prefetch-yarn-deps fixup-yarn-lock];
    phases = ["unpackPhase" "configurePhase" "buildPhase" "installPhase"];
    passthru.exePath = "${finalAttrs.finalPackage}/bin/sf";

    configurePhase = ''
      export HOME=$PWD/yarn_home
      yarn --offline config set yarn-offline-mirror ${offlineCache}
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
      mv bin/run.js $out/bin/sf
      # necessary for some runtime configuration
      cp ./package.json $out
      patchShebangs $out
    '';
  })
