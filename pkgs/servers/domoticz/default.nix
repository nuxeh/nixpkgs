{ stdenv, fetchzip, cmake}:

stdenv.mkDerivation rec {
  pname = "demoticz";
  version = "2020.1";

  # src = ...

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
  ];

  meta = with stdenv.lib; {
    description = "Domoticz home automation system";
    longDescription = ''
      Domoticz is a home automation system that lets you monitor and configure
      various devices like: lights, switches, various sensors/meters like
      temperature, rain, wind, UV, electra, gas, water and much more
    '';
    homepage = "https://www.domoticz.com/";
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}

