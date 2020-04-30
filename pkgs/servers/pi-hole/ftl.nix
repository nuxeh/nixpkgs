{ stdenv,
  fetchzip, 
}:

stdenv.mkDerivation rec {
  name = "pi-hole-ftl";
  version = "v4.3.1";

  src = fetchzip {
    url = "https://github.com/pi-hole/FTL/archive/${version}.tar.gz";
    sha = "05bvwmfqg52ic7f95d419hnqnxlixnqzx2fi93ki3axxz1g56l6p";
  };

  meta = with stdenv.lib; {
    description = "Pi-hole FTL engine";
    homepage = "https://github.com/pi-hole/FTL";
    license = licenses.gpl2;
    maintainers = with maintainers; [ auntie DerTim1 yorickvp ];
    platforms = platforms.all;
  };
}
