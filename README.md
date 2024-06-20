# sfdx-nix

Simple Nix flake that provides the [SFDX CLI](https://developer.salesforce.com/tools/sfdxcli). You can use it like any other flake.

This project is in no way affiliated with Salesforce.

This project's license only covers the code in this repository, and is licensed
under the same license that the SFDX CLI itself is.

## Usage

I hope the usage should be self-explanatory. This flake can be used like any other flake. For example, within the CLI:

```sh
nix run github:rfaulhaber/sfdx-nix
```

is the same as just running `sf`. Similarly,

``` sh
nix shell github:rfaulhaber/sfdx-nix
```

will add the `sf` command to your environment.

You can add it to a NixOS configuration like any other flake as well.
