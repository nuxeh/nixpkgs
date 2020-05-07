{ pkgs, lib, config, ... }:

with lib;

let

  cfg = config.services.pihole-ftl;
  stateDir = "/var/lib/pihole";

in {

  options.services.pihole-ftl = {
    enable = mkEnableOption "Pi-hole FTL";
  };

  config = mkIf cfg.enable {

    users.users.pihole = {
      description = "Pi-hole user";
      group = "pihole";
      home = cfg.stateDir;
      createHome = true;
      isSystemUser = true;
    };

    users.groups.pihole = {};

    systemd.services.pihole-ftl = {
      description = "Pi-hole FTL service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "pihole";
        StateDirectory = $stateDir;
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" "CAP_NET_ADMIN+eip" ];
        ExecStart = "${pkgs.pihole-ftl}/bin/pihole-FTL";
      };
    };

    environment.systemPackages = [ pkgs.pihole-ftl ];

  };

}
