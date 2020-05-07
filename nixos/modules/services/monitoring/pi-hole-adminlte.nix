{ options, config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.grafana;

in {

  options.services.grafana = {
    enable = mkEnableOption "pi-hole-adminlte";

    webserver = mkOption {
      description = "Which web server to configure.";
      default = "lighttpd";
      type = types.enum ["lighttpd" "nginx"];
    };

    stateDir = mkOption {
      description = "Data directory.";
      default = "/var/lib/grafana";
      type = types.path;
    };

  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.pi-hole-ftl ];
    services.pi-hole-ftl.enable = true;

    services.lighttpd = {
      enable = true;
    };

    services.nginx = {
      enable = true;
    };

    systemd.services.pi-hole-adminlte = {
      description = "Pi-hole AdminLTE interface";
      after = ["networking.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        WorkingDirectory = cfg.dataDir;
        User = "pihole";
        ExecStart = "";
      };
      preStart = ''
        ln -fs ${cfg.package}/share/grafana/conf ${cfg.dataDir}
        ln -fs ${cfg.package}/share/grafana/tools ${cfg.dataDir}
      '';
    };

    users.users.pihole = {
      uid = config.ids.uids.pihole;
      description = "Pi-hole user";
      home = cfg.stateDir;
      createHome = true;
      group = "pihole";
    };

    users.groups.pihole = {};
  };
}
