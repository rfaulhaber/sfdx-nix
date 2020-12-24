{ pkgs ? import <nixpkgs> { } }:

let sfdx = import ./sfdx.nix pkgs;
in pkgs.mkShell { buildInputs = with pkgs; [ vscode sfdx ]; }
