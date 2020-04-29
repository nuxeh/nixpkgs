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

      bind = mkOption {
        type = types.str;
        default = "0.0.0.0";
        description = "IP address to bind to.";
      };

      port = mkOption {
        type = types.int;
        default = 8080;
        description = "Port to bind to for HTTP, set to 0 to disable HTTP.";
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
      environment = {
        # to cope with use of runtime linking using dlopen(3)
        # Python is already a required build-time dependency,
        # so it should be present at runtime
        LD_LIBRARY_PATH = "${pkgs.python3}";
      };
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "always";
        ExecStart = ''
          ${pkgs.domoticz}/domoticz -userdata ${cfg.stateDir} -noupdates -www ${toString cfg.port} -wwwbind ${cfg.bind} -sslwww 0
        '';
      };
    };

  };

}
