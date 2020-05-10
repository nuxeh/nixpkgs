{ options, config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.pihole-admin;
  pkgName = "pihole-admin";

in {

  options.services.pihole-admin = {

    enable = mkEnableOption "pihole-admin";

    subdir = mkOption {
      default = "pihole";
      example = "admin";
      type = types.str;
      description = ''
	      The subdirectory in which to serve the Pi-hole admin interface. The
        web application will be accessible at http://yourserver/''${subdir}
      '';
    };

    stateDir = mkOption {
      description = "Data directory.";
      default = "/var/lib/pihole";
      type = types.path;
    };

  };

  config = mkIf cfg.enable {

    users.users.pihole = {
      description = "Pi-hole user";
      group = "pihole";
      home = cfg.stateDir;
      createHome = true;
      isSystemUser = true;
      extraGroups = [ "lighttpd" ];
    };

    users.groups.pihole = {};

    services.phpfpm.pools.pihole-admin = {
      user = "lighttpd";
      phpOptions = ''
        error_log = 'stderr'
        log_errors = on
        post_max_size = 25M
        upload_max_filesize = 25M
      '';
      settings = mapAttrs (name: mkDefault) {
        "listen.owner" = "lighttpd";
        "listen.group" = "lighttpd";
        "listen.mode" = "0660";
        "pm" = "dynamic";
        "pm.max_children" = 75;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 20;
        "pm.max_requests" = 500;
        "catch_workers_output" = true;
      };
    };

    services.lighttpd.enableModules = [
      "mod_alias"
      "mod_access"
      "mod_auth"
      "mod_expire"
      "mod_compress"
      "mod_redirect"
      "mod_setenv"
      "mod_rewrite"
      "mod_fastcgi"
    ];

    services.lighttpd.extraConfig = ''
      fastcgi.server = (
        ".php" => (
          "localhost" => (
            "socket" => "/run/phpfpm/pihole-admin.sock",
            "broken-scriptfilename" => "enable"
          )
        )
      )

      index-file.names += ("index.php")

      $HTTP["url"] =~ "^/${cfg.subdir}" {
        alias.url = (
          "/${cfg.subdir}" => "${pkgs.pihole-admin}/share/pihole-admin/www/index.php",
        )
        setenv.add-response-header = (
          "X-Pi-hole" => "The Pi-hole Web interface is working!",
          "X-Frame-Options" => "DENY"
        )
        #$HTTP["url"] =~ ".ttf$" {
        #  setenv.add-response-header = ( "Access-Control-Allow-Origin" => "*" )
        #}
      }
      #$HTTP["url"] =~ "^/${cfg.subdir}/\.(.*)" {
      #   url.access-deny = ("")
      #}
    '';

    systemd.services.lighttpd.preStart = ''
    '';

    services.lighttpd.enable = true;

    systemd.services.pihole-admin = {
      description = "Pi-hole AdminLTE interface";
      after = ["networking.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        WorkingDirectory = cfg.stateDir;
        User = "pihole";
        ExecStart = "";
      };
      preStart = ''
      '';
    };

    environment.systemPackages = [
      pkgs.pihole-admin
    ];

  };
}
