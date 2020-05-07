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
      example = "";
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
    };

    users.groups.pihole = {};

    services.lighttpd.enableModules = [
      "mod_access"
      "mod_auth"
      "mod_expire"
      "mod_compress"
      "mod_redirect"
      "mod_setenv"
      "mod_rewrite"
    ];

    services.lighttpd.extraConfig = ''
      $HTTP["url"] =~ "^/${cfg.subdir}" {
        alias.url = (
          "/${cfg.subdir}" => "${pkgs.pihole-admin}/share/pihole-admin/www/index.php"
        )
        setenv.add-response-header = (
          "X-Pi-hole" => "The Pi-hole Web interface is working!",
          "X-Frame-Options" => "DENY"
        )
        $HTTP["url"] =~ ".ttf$" {
          setenv.add-response-header = ( "Access-Control-Allow-Origin" => "*" )
        }
      }
      $HTTP["url"] =~ "^/admin/\.(.*)" {
         url.access-deny = ("")
      }
    '';

    systemd.services.lighttpd.preStart = ''
      mkdir -p /var/cache/cgit
      chown lighttpd:lighttpd /var/cache/cgit
    '';

    systemd.services.pihole-admin = {
      description = "Pi-hole AdminLTE interface";
      after = ["networking.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        WorkingDirectory = cfg.dataDir;
        User = "pihole";
        ExecStart = "";
      };
      preStart = ''
      '';
    };

    services.pihole-ftl.enable = true;

    environment.systemPackages = [ cfg.pihole-ftl ];
    environment.systemPackages = [ cfg.pihole ];

  };
}
