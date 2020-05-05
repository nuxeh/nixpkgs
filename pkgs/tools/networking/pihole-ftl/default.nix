{ stdenv,
  fetchzip,
  fetchgit,
  nettle,
  gmp,
  git
}:

stdenv.mkDerivation rec {
  name = "pihole-ftl";
  version = "v5.0";
  gitRef = "01332f610120f2611cd621372f66c18375033407";
  gitBranch = "release/${version}";

  src = fetchgit {
    url = "https://github.com/nuxeh/FTL.git";
    rev = "${gitRef}";
    sha256 = "0zbpkgy5pcwi6z1hsnf2y44g12wm8ja39nvb5iqshv3zip7nahfj";
  };

  enableParallelBuilding = true;

  buildInputs = [
    nettle
    gmp
    git
  ];

  preBuild = ''
    # Initialise a git repo to please the build system
    git init; git add .
    git config user.name nixbld
    git config user.email nixbld
    git commit -m "Nix build ${version} at ${gitRef}"

    # override git variables
    makeFlagsArray+=(GIT_HASH="${gitRef}")
    makeFlagsArray+=(GIT_BRANCH="${gitBranch}")

    # disable static linking
    makeFlagsArray+=(LIBS="-pthread -lrt -lhogweed -lgmp -lnettle")
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
