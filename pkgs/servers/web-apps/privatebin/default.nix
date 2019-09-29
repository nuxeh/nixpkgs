{ stdenv, fetchzip, php}:

stdenv.mkDerivation rec {
  name = "privatebin-${version}";
  version = "1.3.1";

  src = fetchzip {
    url = "https://github.com/PrivateBin/PrivateBin/archive/${version}.tar.gz";
    sha256 = "1gzd7b2l7258blgify0m728m8skjlcj528a6gn24834vfhar9i82";
  };

  buildPhase = "";

  installPhase = ''
    mkdir $out
    cp -r * $out/
    ln -sf /etc/privatebin/conf.php $out/cfg/conf.php
  '';

  meta = with stdenv.lib; {
    description = "PrivateBin pas";
    longDescription = ''
      A minimalist, open source online pastebin where the server has zero
      knowledge of pasted data. Data is encrypted/decrypted in the browser
      using 256 bits AES.
    '';
    homepage = "https://privatebin.info/";
    license = licenses.zlib;
    platforms = platforms.all;
  };
}
