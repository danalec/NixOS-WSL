{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  name = "cargo-audit-check";

  src = ./.;

  buildInputs = with pkgs; [ cargo cargo-audit ];

  buildPhase = ''
    cd utils
    cargo audit
  '';

  installPhase = ''
    touch $out
  '';

  dontUnpack = true;
}

