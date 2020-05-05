{ stdenv,
  fetchzip,
  nettle,
  gmp,
  git
}:

stdenv.mkDerivation rec {
  name = "pihole-ftl";
  version = "v5.0";
  gitRef = "01332f610120f2611cd621372f66c18375033407";
  gitBranch = "release/${version}";

  src = fetchzip {
    url = "https://github.com/pi-hole/FTL/archive/${version}.tar.gz";
    sha256 = "1pz7azqi1mpxwgshnc4n8x07hkipl7h3808zcdpzwg0wrg3yp42s";
  };

  enableParallelBuilding = true;

  buildInputs = [
    nettle
    gmp
    git
  ];

  patchPhase = ''
    # remove a couple of irrelevant usage strings - `service pihole-FTL start`
    substituteInPlace src/args.c --replace 'printf("Usage:' '//printf("Usage:'
    substituteInPlace src/args.c --replace 'printf("where ' '//printf("where '
  '';

  preBuild = ''
    # Initialise a git repo to please the build system
    git init; git add .
    git config user.name nixbld
    git config user.email nixbld
    git commit -m "Nix build ${version} at ${gitRef}"
    git tag ${version}

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
