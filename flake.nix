{
  inputs = {
    poetry2nix.url = "github:nix-community/poetry2nix";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = inputs@{self, nixpkgs, ...}: inputs.flake-utils.lib.eachDefaultSystem (system: let
    pkgs = nixpkgs.legacyPackages.${system}.extend inputs.poetry2nix.overlay;
  in rec {
    packages.rmrl = pkgs.poetry2nix.mkPoetryApplication {
      projectDir = ./.;
      overrides = pkgs.poetry2nix.overrides.withDefaults (self: super: {
        tinycss2 = super.tinycss2.overridePythonAttrs (old: {
          buildInputs = (old.buildInputs or []) ++ [ self.flit-core ];
        });
      });
    };
    defaultPackage = packages.rmrl;
    apps.rmrl = inputs.flake-utils.lib.mkApp { drv = packages.rmrl; };
    defaultApp = apps.rmrl;
  });
}
