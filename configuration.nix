{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  environment.systemPackages = with pkgs; [
    vim
    #pihole
    #pihole-ftl
    amp
  ];

  services.pihole = {
    enable = true;
    interface = "ens3";
    webInterface = true;
  };

  #services.pihole-admin = {
  #  enable = true;
  #};

  services.lighttpd.cgit.enable = true;
  services.lighttpd.gitweb.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  programs.fish.enable = true;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  users.users.root = {
    password = "qqcTch4m";
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDdL7NHNyU2XmINaKEPJ/NCatr4luz+w2Fj841Ljvqjpd8SWG80mfuib105n6+lh69ueDF0QAK0lyGdRiQ41hJbDZpag8tFhw1Qm8Db3pz6T1Oir89m6DyGZrnlzb3+lVp1xzh3Yb4bkrp+YNOSF9khzKw/cd6NN7Jk+A1pUFyF4usCvuWUJIVCqk60kgKKLl5ZLdr4gMM1CFc0gUQBMF5hARDLzGH6uCMRwRmkIEkrNj1jDCJmH5EkQQP2zA9wU4KF17pleO74foAFA6ZsY33pLtotdONlDRhAg21Bw7q4Lbq21W6kmt75bn9iebKNyGiNzz2HEix6VDUQLOK+BLed ed@dinkydos"];
  };

  system.stateVersion = "18.09";
}
