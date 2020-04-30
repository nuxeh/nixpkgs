{ stdenv,
  fetchgit,
  makeWrapper,
  cmake,
  python3,
  openssl,
  pkg-config,
  mosquitto,
  lua5_3,
  sqlite,
  jsoncpp,
  zlib,
  boost,
  curl,
  git,
  libusb,
  cereal
}:

stdenv.mkDerivation rec {
  name = "domoticz";
  version = "2020.2";

  src = fetchgit {
    url = "https://github.com/domoticz/domoticz.git";
    rev = "aad65002eea99b8336cefd773e7422f0a7f1873f";
    sha256 = "06vi9ambn285z8v7n9h85lcx77nvw1s9h78719fll5czzmm250xx";
    deepClone = true;
    fetchSubmodules = true;
  };

  enableParallelBuilding = true;

  buildInputs = [
    openssl
    python3
    mosquitto
    lua5_3
    sqlite
    jsoncpp
    boost
    zlib
    curl
    git
    libusb
    cereal
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DUSE_BUILTIN_MQTT=false"
    "-DUSE_BUILTIN_LUA=false"
    "-DUSE_BUILTIN_SQLITE=false"
    "-DUSE_BUILTIN_JSONCPP=false"
    "-DUSE_BUILTIN_ZLIB=false"
    "-DUSE_OPENSSL_STATIC=false"
    "-DUSE_STATIC_BOOST=false"
    "-DUSE_BUILTIN_MINIZIP=true"
  ];

  postInstall = ''
    wrapProgram $out/domoticz --set LD_LIBRARY_PATH ${python3}/lib;
  '';

  meta = with stdenv.lib; {
    description = "Home automation system";
    longDescription = ''
      Domoticz is a home automation system that lets you monitor and configure
      various devices like: lights, switches, various sensors/meters like
      temperature, rain, wind, UV, electra, gas, water and much more
    '';
    maintainters = with maintainers; [ edcragg ];
    homepage = "https://www.domoticz.com/";
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
