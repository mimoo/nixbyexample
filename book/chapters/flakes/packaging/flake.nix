{
  description = "My own hello world";

  outputs = { self, nixpkgs }: 
    let 
      build_for = system:
        let 
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.stdenv.mkDerivation {
          name = "hello";
          src = self;
          buildInputs = [ pkgs.gcc pkgs.which ];
          buildPhase = "gcc -o hello ./hello.c";
          installPhase = "mkdir -p $out/bin; install -t $out/bin hello";
        };
    in
    {
      packages.x86_64-darwin.default = build_for "x86_64-darwin";
      packages.x86_64-linux.default = build_for "x86_64-linux";
    };
}