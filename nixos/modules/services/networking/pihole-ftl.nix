{ pkgs, lib, config, ... }:

with lib;

let

  cfg = config.services.pihole-ftl;
  stateDir = "/var/lib/pihole";

in {

  options.services.pihole-ftl = {

    enable = mkEnableOption "Pi-hole FTL";

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to open port 53.";
    };

  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.pihole-ftl ];

    services.dnsmasq.enable = false;

    systemd.services.pihole-ftl = {
      description = "Pi-hole FTL service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "pihole";
        StateDirectory = stateDir;
        CapabilityBoundingSet = [ "cap_net_bind_service" "cap_net_raw" "cap_net_admin+eip" ];
        AmbientCapabilities = [ "cap_net_bind_service" "cap_net_raw" "cap_net_admin+eip" ];
        ExecStart = "${pkgs.pihole-ftl}/bin/pihole-FTL";
      };
    };

    system.activationScripts.pihole-ftl = ''
      touch /var/log/pihole-FTL.log
      chown pihole:pihole /var/log/pihole-FTL.log
    '';

  };

  # TODO
  # - Get pihole user from pihole configuration

}
