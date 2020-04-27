let
  overlay = self: super: {
    domoticz = self.callPackage ./default.nix {};
  };
  pkgs = import <nixpkgs> {
    config = {};
    overlays = [ overlay ];
  };
in pkgs.domoticz
