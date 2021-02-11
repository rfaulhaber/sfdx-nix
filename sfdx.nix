{ lib, pkgs, stdenv, fetchurl, nodejs, ... }:

stdenv.mkDerivation {
  pname = "sfdx";
  version = "7.82.1-0";

  src = fetchurl {
    url =
      "https://developer.salesforce.com/media/salesforce-cli/sfdx-linux-amd64.tar.xz";
    sha256 = "qHslfEamZp5JvxjSbHeMmQj3/ibYDQtWXYAp83AkHws=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp -a * $out/lib
    echo "${nodejs}/bin/node $out/lib/bin/sfdx.js \$@"  >> $out/bin/sfdx
    chmod 755 $out/bin/sfdx
  '';
}
