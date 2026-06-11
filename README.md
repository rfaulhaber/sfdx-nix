# sfdx-nix

Simple Nix flake that provides the [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli) for Salesforce. You can use it like any other flake.

This project is in no way affiliated with Salesforce.

This project's license only covers the code in this repository, and is licensed
under the same license that the Salesforce CLI itself is.

## Usage

This flake can be used like any other flake. For example, within the CLI:

```sh
nix run github:rfaulhaber/sfdx-nix
```

is the same as just running `sf`. Similarly,

``` sh
nix shell github:rfaulhaber/sfdx-nix
```

will add the `sf` command to your environment.

You can add it to a NixOS configuration like any other flake as well. Something like this should work:

```nix
{
  inputs = {
    nixpkgs = "github:NixOS/nixpkgs";
    sfdx-nix = "github:rfaulhaber/sfdx-nix";
  };
  outputs = {
    nixpkgs,
    sfdx-nix,
    ...
  }: {
    nixosConfigurations.your-machine = nixpkgs.lib.nixosSystem {
      # see flake.nix for supported systems
      system = "x86_64-linux";
      modules = [
        # ...
        {...}: {
          # or added to your user packages
          environment.systemPackages = [
            sfdx-nix.packages."x86_64-linux".default
          ];
        }
      ];
    };
  };
}
```

Previously this flake was built to support `sfdx` and `sf` executable, however now that Salesforce has retired `sfdx` the package/app default exported by this flake is `sf`.

## Build Cache

I maintain a build cache for this project with Cachix [here](https://app.cachix.org/cache/sfdx-nix).
