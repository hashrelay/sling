{
  description = "A core lightning plugin to automatically rebalance multiple channels";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, ... }:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        craneLib = inputs.crane.mkLib pkgs;
        crate = craneLib.buildPackage {
          name = "sling";
          src = craneLib.cleanCargoSource (craneLib.path ./.);
        };
      in
      {
        checks = {
          inherit crate;
        };
        packages.default = crate;
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = craneLib.devShell {
          checks = self.checks.${system};
        };
      });
}
