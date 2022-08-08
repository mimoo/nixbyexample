# flake taken from github.com/brendanzab/ocaml-flake-example
{
  description = "The nixbyexample flake";

  inputs = {
    # Convenience functions for writing flakes
    flake-utils.url = "github:numtide/flake-utils";

    # Precisely filter files copied to the nix store
    nix-filter.url = "github:numtide/nix-filter";
  };
  
  outputs = { self, nixpkgs, flake-utils, nix-filter }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Legacy packages that have not been converted to flakes
        legacyPackages = nixpkgs.legacyPackages.${system};
        # OCaml packages available on nixpkgs
        ocamlPackages = legacyPackages.ocamlPackages;
        # Library functions from nixpkgs
        lib = legacyPackages.lib;

        # OCaml source files
        ocaml-src = nix-filter.lib.filter {
          root = ./tools;
          include = [
            ".ocamlformat"
            "dune-project"
            "byexample.opam"
            (nix-filter.lib.matchExt "opam")
            (nix-filter.lib.inDirectory "bin")
            (nix-filter.lib.inDirectory "lib")
          ];
        };

        # Nix source files
        nix-src = nix-filter.lib.filter {
          root = ./.;
          include = [
            (nix-filter.lib.matchExt "nix")
          ];
        };
      in
      {
        # Executed by `nix build .#<name>`
        packages = {
          # Executed by `nix build .#byexample`
          byexample = ocamlPackages.buildDunePackage {
            pname = "byexample";
            version = "0.1.0";
            # Would be nice to use dune 3.x, but the odoc package needs to be
            # updated first.
            duneVersion = "3";

            src = ocaml-src;

            outputs = [ "doc" "out" ];

            nativeBuildInputs = [
              ocamlPackages.odoc
            ];

            strictDeps = true;

            preBuild = ''
              dune build ./bin/main.exe
            '';

            postBuild = ''
              echo "building docs"
              dune build @doc -p byexample
            '';

            postInstall = ''
              echo "Installing $doc/share/doc/byexample/html"
              mkdir -p $doc/share/doc/byexample/html
              cp -r _build/default/_doc/_html/* $doc/share/doc/byexample/html
            '';
          };

          # Executed by `nix build`
          default = self.packages.${system}.byexample;
        };

        # Executed by `nix run .#<name> <args?>`
        apps = {
          # Executed by `nix run .#byexample`
          byexample = {
            type = "app";
            program = "${self.packages.${system}.byexample}/bin/byexample";
          };

          # Executed by `nix run`
          default = self.apps.${system}.byexample;
        };


        # Used by `nix develop`
        devShells = {
          default = legacyPackages.mkShell {
            # Development tools
            packages = [
              # Source file formatting
              legacyPackages.nixpkgs-fmt
              legacyPackages.ocamlformat
              # For `dune build --watch ...`
              legacyPackages.fswatch
              # OCaml editor support
              ocamlPackages.ocaml-lsp
              # Nicely formatted types on hover
              ocamlPackages.ocamlformat-rpc-lib
              # Fancy REPL thing
              ocamlPackages.utop
            ];

            # Tools from packages
            inputsFrom = [
              self.packages.${system}.byexample
            ];
          };
        };
      });
}
