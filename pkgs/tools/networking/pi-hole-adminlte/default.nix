{ stdenv, fetchzip }:

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
    mkdir -p $out/share/$name/www
    cp *.php $out/share/$name/www
    cp .user.php.ini $out/share/$name/www
    cp -r scripts $out/share/$name/www
    cp -r img $out/share/$name/www
    cp -r style $out/share/$name/www
  '';

  meta = with stdenv.lib; {
    description = "Pi-hole AdminLTE web UI";
    homepage = "https://github.com/pi-hole/AdminLTE";
    license = licenses.eupl11; ## TODO eupl12
    maintainers = with maintainers; [ edcragg ];
    platforms = platforms.all;
  };
}

