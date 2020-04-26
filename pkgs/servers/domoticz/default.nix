{ stdenv, fetchzip, cmake, python3, openssl, pkgconfig, mosquitto, lua5_3, sqlite }:

stdenv.mkDerivation rec {
  pname = "demoticz";
  version = "2020.1";

   src = fetchzip {
     url = "https://github.com/domoticz/domoticz/archive/${version}.tar.gz";
     sha256 = "1cc9l5r9f4jczmxn9a9chh9nap2njs8r69wkn0zmwqwcpzb5qna5";
   };

  buildInputs = [ openssl python3 mosquitto lua5_3 sqlite ];
  nativeBuildInputs = [ cmake pkgconfig ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DUSE_BUILTIN_MQTT=false"
    "-DUSE_BUILTIN_LUA=false"
    "-DUSE_BUILTIN_SQLITE=false"
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

