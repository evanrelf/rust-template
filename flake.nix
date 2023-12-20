{
  description = "template";

  inputs = {
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = inputs@{ flake-utils, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        crane = inputs.crane.lib.${system};
      in
      rec {
        packages = {
          default = packages.template;

          template =
            let
              common = {
                src = crane.cleanCargoSource (crane.path ./.);
                strictDeps = true;
                buildInputs = pkgs.lib.optionals pkgs.stdenv.isDarwin [
                  pkgs.libiconv
                ];
              };
              cargoArtifacts = crane.buildDepsOnly common;
            in
            crane.buildPackage (common // { inherit cargoArtifacts; });
        };

        devShells = {
          default = devShells.template;

          template = crane.devShell {
            inputsFrom = [ packages.template ];
          };
        };

        checks = packages // devShells;
      });
}
