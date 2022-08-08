{
  description = "My own hello world";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      rec {

        packages.hello = pkgs.stdenv.mkDerivation {
          name = "hello";
          src = self;
          buildInputs = [ pkgs.gcc ];
          buildPhase = "gcc -o hello ./hello.c";
          installPhase = "mkdir -p $out/bin; install -t $out/bin hello";
        };

        defaultPackage = packages.hello;

      }
    );
}
