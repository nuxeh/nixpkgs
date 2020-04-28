{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.services.domoticz;

  pkgName = "domoticz";
  pkgDesc = "Domoticz home automation";

in {

  options = {

    services.domoticz = {
      enable = mkEnableOption pkgDesc;

      user = mkOption {
        type = types.str;
        default = "domoticz";
        description = "domoticz user";
      };

      group = mkOption {
        type = types.str;
        default = "domoticz";
        description = "domoticz group";
      };

      extraGroups = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Extra groups to add to domoticz user";
      };

      stateDir = mkOption {
        type = types.path;
        default = "/var/lib/domoticz/";
        description = ''
          The state directory for InspIRCd.
        '';
        example = "/home/bob/.domoticz/";
      };

    };

  };

  config = mkIf cfg.enable {

    users.users."domoticz" = {
      name = cfg.user;
      group = cfg.group;
      extraGroups = cfg.extraGroups;
      home = cfg.stateDir;
      createHome = true;
      description = pkgDesc;
    };

    users.groups."domoticz" = {
      name = cfg.group;
    };

    systemd.services."domoticz" = {
      description = pkgDesc;
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "always";
        ExecStart = ''
          ${pkgs.domoticz}/bin/domoticz -userdata ${cfg.stateDir}
        '';
      };
    };

  };

}
