{ stdenv,
  fetchzip,
}:

stdenv.mkDerivation rec {
  name = "pi-hole-adminlte";
  version = "v4.3.3";

  src = fetchzip {
    url = "https://github.com/pi-hole/AdminLTE/archive/${version}.tar.gz";
    sha256 = "0y820v2rl35d9m4x5y8z0hhk5yf2ppyp3g71pgbh8g3qmp8p2m87";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
#    mkdir -p $out/bin
#    cp pihole $out/bin
#
#    mkdir -p $out/opt/pihole
#    cp gravity.sh $out/opt/pihole
#    cp advanced/Scripts/*.sh $out/opt/pihole
#    cp advanced/Scripts/COL_TABLE $out/opt/pihole
#
#    mkdir -p $out/etc/bash_completion.d/
#    cp advanced/bash-completion/pihole $out/etc/bash_completion.d/
  '';

  meta = with stdenv.lib; {
    description = "Pi-hole AdminLTE web UI";
    homepage = "https://github.com/pi-hole/AdminLTE";
    license = licenses.eupl11; ## TODO eupl12
    maintainers = with maintainers; [ edcragg ];
    platforms = platforms.all;
  };
}

