{ stdenv,
  fetchzip,
  fetchgit,
  nettle,
  gmp
}:

let

  # It's tricky to have .git present at build time, but the Makefile shells
  # out to git expecting to fill the following values, which need to be
  # set, or we get build errors.
  gitHash = "01332f610120f2611cd621372f66c18375033407";
  gitBranch = "release/v5.0";
  gitVersion = "v4.3.1-820-g01332f6";
  gitDate = "2020-05-05 21:19:48 +0200";
  gitTag = "v4.3.1";

in stdenv.mkDerivation rec {
  name = "pihole-ftl";
  version = "v5.0";

  src = fetchgit {
    url = "https://github.com/nuxeh/FTL.git";
    rev = "${gitHash}";
    sha256 = "0zbpkgy5pcwi6z1hsnf2y44g12wm8ja39nvb5iqshv3zip7nahfj";
  };

  enableParallelBuilding = true;

  buildInputs = [
    nettle
    gmp
  ];

  preBuild = ''
    # disable static linking
    makeFlagsArray+=(LIBS="-pthread -lrt -lhogweed -lgmp -lnettle")
    # override git variables
    makeFlagsArray+=(GIT_HASH="${gitHash}")
    makeFlagsArray+=(GIT_BRANCH="${gitBranch}")
    makeFlagsArray+=(GIT_VERSION="${gitVersion}")
    makeFlagsArray+=(GIT_DATE="${gitDate}")
    makeFlagsArray+=(GIT_TAG="${gitTag}")
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp pihole-FTL $out/bin
  '';

  meta = with stdenv.lib; {
    description = "Pi-hole FTL engine";
    homepage = "https://github.com/pi-hole/FTL";
    license = licenses.eupl11; ## TODO eupl12
    #maintainers = with maintainers; [ edcragg ];
    platforms = platforms.all;
  };
}
