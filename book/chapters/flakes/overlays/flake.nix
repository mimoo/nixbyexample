{
  description = "overlay example";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          self.overlays.default
        ];
        config = { allowUnfree = true; };
      };
    in {
      overlays.default =  (final: prev: rec {

      });
    };
}
