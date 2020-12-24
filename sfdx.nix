{ lib, pkgs, stdenv, fetchurl, nodejs, ... }:

stdenv.mkDerivation {
  pname = "sfdx";
  version = "7.82.1-0";

  src = fetchurl {
    url =
      "https://developer.salesforce.com/media/salesforce-cli/sfdx-linux-amd64.tar.xz";
    sha256 = "1hhaqd11a31izi81bz8r8vfivljz3siczmy3bm0dxq2cxs3klp7x";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp -a * $out/lib
    echo "${nodejs}/bin/node $out/lib/bin/sfdx.js \$@"  >> $out/bin/sfdx
    chmod 755 $out/bin/sfdx
  '';
}
