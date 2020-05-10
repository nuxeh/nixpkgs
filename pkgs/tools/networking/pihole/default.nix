{ stdenv,
  fetchzip,
}:

stdenv.mkDerivation rec {
  name = "pi-hole";
  version = "v4.4";

  src = fetchzip {
    url = "https://github.com/pi-hole/${name}/archive/${version}.tar.gz";
    sha256 = "12h6xri08x6fm6x3ixhr7yacl56azgw6ab7cznlr4ykbphwrgy70";
  };

  dontConfigure = true;
  dontBuild = true;

  patchPhase = ''
    #map
    substituteInPlace pihole \
      --replace /usr/local/bin $out/bin \
      --replace /opt/pihole $out/opt/pihole \
      --replace /etc/pihole $out/etc/pihole

    substituteInPlace gravity.sh \
      --replace /opt/pihole $out/opt/pihole \
      --replace /etc/pihole $out/etc/pihole \
      --replace /usr/local/bin $out/bin \
      --replace "piholeDir=\"/etc/" "piholeDir=\"$out/etc/pihole/\""

    substituteInPlace advanced/Scripts/piholeDebug.sh \
      --replace /opt/pihole $out/opt/pihole \
      --replace /etc/pihole $out/etc/pihole \
      --replace /usr/local/bin $out/bin \
      --replace "piholeDir=\"/etc/" "piholeDir=\"$out/etc/pihole/\""

    substituteInPlace advanced/Scripts/version.sh --replace "-1" $version
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp pihole $out/bin

    mkdir -p $out/opt/pihole
    cp gravity.sh $out/opt/pihole
    cp advanced/Scripts/*.sh $out/opt/pihole
    cp advanced/Scripts/COL_TABLE $out/opt/pihole

    mkdir -p $out/etc/bash_completion.d/
    cp advanced/bash-completion/pihole $out/etc/bash_completion.d/

    #wrapProgram $out/opt/gravity.sh --set piholeDir $out/etc/pihole;
  '';

  meta = with stdenv.lib; {
    description = "Pi-hole core";
    homepage = "https://github.com/pi-hole/pi-hole";
    license = licenses.eupl11; ## TODO eupl12
    maintainers = with maintainers; [ edcragg ];
    platforms = platforms.all;
  };
}

