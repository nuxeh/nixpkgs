  let
    overlay = self: super: {
      pi-hole-fl = self.callPackage ./default.nix {};
    };
    pkgs = import <nixpkgs> {
      config = {};
      overlays = [ overlay ];
    };
  in pkgs.pi-hole-fl
