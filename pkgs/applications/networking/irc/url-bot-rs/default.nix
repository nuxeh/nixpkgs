{ stdenv
, lib
, pkgs
, rustPlatform
, fetchFromGitHub

# native
, pkg-config

# build
, openssl
, sqlite

# darwin
, libiconv
, Security
}:

let
  pname = "url-bot-rs";
  version = "v0.4.0-rc.2";
  owner = "nuxeh";
  repo = pname;
in
rustPlatform.buildRustPackage {
  inherit pname version;

  src = fetchFromGitHub {
    inherit owner repo;
    rev = "v${version}";
    sha256 = "AjV1GAT9PzIFjHaTK25AkdZBmqTdF5ygEQi0Rs1R5V8=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    sqlite
  ] ++ lib.optionals stdenv.isDarwin [
    libiconv
    Security
  ];

  preBuild = ''
    export HOME=$TMPDIR
  '';

  passthru.updateScript = pkgs.writeScript "url-bot-rs-updater" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p common-updater-scripts curl jq

    set -euo pipefail

    version=$(curl https://api.github.com/repos/${owner}/${repo}/releases/latest | jq --exit-status -r ".tag_name")
    curl -o ${toString ./Cargo.lock} https://raw.githubusercontent.com/${owner}/${repo}/$version/Cargo.lock
    update-source-version ${pname} "''${version#v}"
  '';

  meta = with lib; {
    description = "Minimal IRC URL bot in Rust";
    homepage = "https://github.com/nuxeh/url-bot-rs";
    license = licenses.isc;
    maintainers = with maintainers; [ hexa ];
  };
}
