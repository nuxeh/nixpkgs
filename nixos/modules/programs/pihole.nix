{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.programs.pihole;

in

{

  options = {

    programs.pihole = {

      enable = mkEnableOption "pihole";

      interface = mkOption {
        type = types.str;
        description = ''
          Network interface to run Pi-hole on.
        '';
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

    environment.systemPackages = [
      pkgs.pihole
      pkgs.pihole-ftl
    ];

  };

}
