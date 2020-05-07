{ pkgs, lib, config, ... }:

with lib;

let

  cfg = config.services.pi-hole-ftl;
  stateDir = "/var/lib/pi-hole";

in {

  options.services.pi-hole-ftl = {
    enable = mkEnableOption "Pi-hole FTL";
  };

  config = mkIf cfg.enable {

    users.users.pihole = {
      description = "Pi-hole user";
      group = "pihole";
      createHome = true;
      isSystemUser = true;
    };

    users.groups.pihole = {};

    systemd.services.pi-hole-ftl = {
      description = "Pi-hole FTL service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "pihole";
        StateDirectory = $stateDir;
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" "CAP_NET_ADMIN+eip" ];
        ExecStart = "${pkgs.pi-hole-ftl}/bin/pihole-FTL";
      };
    };

    environment.systemPackages = [ pkgs.pi-hole-ftl ];

  };

}
