{ stdenv, fetchzip, cmake, python3, openssl_1_0_2, pkgconfig }:

stdenv.mkDerivation rec {
  pname = "demoticz";
  version = "2020.1";

   src = fetchzip {
     url = "https://github.com/domoticz/domoticz/archive/${version}.tar.gz";
     sha256 = "1cc9l5r9f4jczmxn9a9chh9nap2njs8r69wkn0zmwqwcpzb5qna5";
   };

  buildInputs = [ openssl_1_0_2 python3 ];
  nativeBuildInputs = [ cmake pkgconfig ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
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

