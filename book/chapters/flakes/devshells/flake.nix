{
  description = "My own hello world";

  outputs = { self, nixpkgs }: (
    let 
      build_for = system:
        let 
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.stdenv.mkDerivation {
          name = "hello";
          src = self;
          buildInputs = [ pkgs.gcc ];
          buildPhase = "gcc -o hello ./hello.c";
          installPhase = "mkdir -p $out/bin; install -t $out/bin hello";
        };
      shell_for = system:
        let 
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.mkShell {
          packages = [
            pkgs.gcc
            pkgs.python
          ];
        };
    in
    {
      packages.x86_64-darwin.default = build_for "x86_64-darwin";
      packages.x86_64-linux.default = build_for "x86_64-linux";

      devShells.x86_64-darwin.default = shell_for "x86_64-darwin";
      devShells.x86_64-linux.default = shell_for "x86_64-linux";
    });
}