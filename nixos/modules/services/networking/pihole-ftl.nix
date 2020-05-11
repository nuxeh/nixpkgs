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

    config = mkOption {
      type = types.str;
      default = null;
      example = ''

      '';
      description = ''
        Configuration file content to provide for pihole-FTL. This configuration is
        not compulsory, if not provided it will use default settings.
      '';
    };

  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.pihole-ftl ];

    services.dnsmasq.enable = false;

    # TODO: open firewall
    # TODO: write out configuration

    security.wrappers.pihole-FTL = {
      source = "${pkgs.pihole-ftl}/bin/pihole-FTL";
      capabilities = "cap_net_bind_service,cap_net_raw,cap_net_admin+eip";
    };

    systemd.services.pihole-ftl = {
      description = "Pi-hole FTL service";
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        # TODO
      '';
      serviceConfig = {
        User = "pihole";
        StateDirectory = stateDir;
        ExecStart = "/run/wrappers/bin/pihole-FTL";
        ExecReload = "${pkgs.coreutils}/bin/kill -9 $MAINPID";
      };
    };

    system.activationScripts.pihole-ftl = ''
      touch /var/log/pihole-FTL.log
      chown pihole:pihole /var/log/pihole-FTL.log
      # TODO: as prestart
    '';

  };

  # TODO
  # - Get pihole user from pihole configuration

}
