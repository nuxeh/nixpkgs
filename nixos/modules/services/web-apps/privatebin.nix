{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.privatebin;

  pname = "privatebin";
  stateDir = "/var/lib/${pname}";

  phpSocket = "/run/phpfpm/${pname}.sock";
  phpExecutionUnit = "phpfpm-${pname}";

  nginxUser = config.services.nginx.user;
  nginxGroup = config.services.nginx.group;

  exampleConf = readFile "${pkgs.privatebin}/cfg/conf.sample.php";

in {

  options = {

    services.privatebin = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable PrivateBin pastebin service";
      };

      hostName  = mkOption {
        type = types.str;
        default = "paste.example.com";
        description = "Host name for nginx vitualHost configuration";
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = "Extra configuration for PrivateBin";
      };

    };

  };

  config = mkIf cfg.enable {

    environment.etc."${pname}/conf.php".text = let
      # substitute paths in example config
      a = "dir = PATH \"data\"";
      b = "dir = PATH \"${stateDir}\"";
      conf = "${replaceStrings ["${a}"] ["${b}"] exampleConf}";
    in ''
      ${conf}
      ${cfg.extraConfig}
    '';

    services.phpfpm.pools.privatebin = {
      user = "${nginxUser}";
      phpOptions = ''
        error_log = 'stderr'
        log_errors = on
        post_max_size = 25M
        upload_max_filesize = 25M
      '';
      settings = mapAttrs (name: mkDefault) {
        "listen.owner" = "${nginxUser}";
        "listen.group" = "${nginxGroup}";
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

    services.nginx = {
      enable = true;
      virtualHosts = {
        ${cfg.hostName} = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            root = "${pkgs.privatebin}";
            index = "index.php";
            extraConfig = ''
              location ~ \.php$ {
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_pass unix:${phpSocket};
                include ${pkgs.nginx}/conf/fastcgi_params;
                include ${pkgs.nginx}/conf/fastcgi.conf;
              }
            '';
          };
        };
      };
    };

    systemd.services.privatebin-setup = {
      serviceConfig.Type = "oneshot";
      script = ''
        # create state directory
        mkdir -m 755 -p ${stateDir}
        chown -R "${nginxUser}" "${stateDir}"
        chmod -R 755 "${stateDir}"
      '';
      wantedBy = [ "multi-user.target" ];
    };

  };
}
