{ stdenv,
  fetchzip,
  nettle,
  gmp
}:

stdenv.mkDerivation rec {
  name = "pi-hole-ftl";
  version = "v4.3.1";

  src = fetchzip {
    url = "https://github.com/pi-hole/FTL/archive/${version}.tar.gz";
    sha256 = "05bvwmfqg52ic7f95d419hnqnxlixnqzx2fi93ki3axxz1g56l6p";
  };

  enableParallelBuilding = true;

  buildInputs = [
    nettle
    gmp
  ];

  # disable static linking
  makeFlags = [ "LIBS=\"-pthread -lrt -lhogweed -lgmp -lnettle\"" ];

  meta = with stdenv.lib; {
    description = "Pi-hole FTL engine";
    homepage = "https://github.com/pi-hole/FTL";
    license = licenses.eupl11; ## TODO eupl12
    maintainers = with maintainers; [ edcragg ];
    platforms = platforms.all;
  };
}
