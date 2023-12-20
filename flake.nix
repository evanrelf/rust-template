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

        checks = packages // { devShell = devShells.default; };

        devShells.default = crane.devShell {
          inputsFrom = [ packages.template ];
        };
      });
}
