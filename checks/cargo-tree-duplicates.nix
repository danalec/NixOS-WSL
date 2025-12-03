{ pkgs, lib, ... }:

pkgs.stdenv.mkDerivation {
  name = "cargo-tree-duplicates";

  src = ./.;

  buildInputs = with pkgs; [ cargo ];

  buildPhase = ''
    cd utils
    DUPS=$(cargo tree -d)
    if [ -n "$DUPS" ]; then
      echo "$DUPS"
      echo "Duplicate crates detected"
      exit 1
    fi
  '';

  installPhase = ''
    touch $out
  '';

  dontUnpack = true;
}

