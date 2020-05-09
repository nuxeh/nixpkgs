{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.pihole;
  stateDir = "/var/lib/pihole";

in

{

  options = {

    services.pihole = {

      enable = mkEnableOption "pihole";

      interface = mkOption {
        type = types.str;
        description = ''
          Network interface to run Pi-hole on.
        '';
      };

      webInterface = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable Pi-hole's AdminLTE interface";
      };

      ipv4 = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "IPv4 address to run Pi-hole on.";
      };

      ipv6 = mkOption {
        type = types.str;
        default = "::1";
        description = "IPv6 address to run Pi-hole on.";
      };

      dnsServer = mkOption {
        type = types.str;
        default = "1.1.1.1";
        description = "IPv4 address to run Pi-hole on.";
      };

      secDnsServer = mkOption {
        type = types.str;
        default = "8.8.8.8";
        description = "IPv6 address to run Pi-hole on.";
      };

    };

  };

  config = mkIf cfg.enable {

    environment.etc."pihole/setupVars.conf ".text = ''
      PIHOLE_INTERFACE=${cfg.interface}
      IPV4_ADDRESS=${cfg.ipv4}
      IPV6_ADDRESS=${cfg.ipv6}
      PIHOLE_DNS_1=${cfg.dnsServer}
      PIHOLE_DNS_2=${cfg.secDnsServer}
      QUERY_LOGGING=true
      INSTALL_WEB_SERVER=false
      INSTALL_WEB_INTERFACE=false
      LIGHTTPD_ENABLED=false
    '';

    users.users.pihole = {
      description = "Pi-hole user";
      group = "pihole";
      home = stateDir;
      createHome = true;
      isSystemUser = true;
    };

    users.groups.pihole = {};

    environment.systemPackages = [ pkgs.pihole ];

    services.pihole-ftl.enable = true;
    services.pihole-admin = mkIf cfg.webInterface {
      enable = true;
    };

  };

}
