{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  name = "cargo-deny-check";

  src = ./.;

  buildInputs = with pkgs; [ cargo cargo-deny ];

  buildPhase = ''
    cd utils
    cargo deny check
  '';

  installPhase = ''
    touch $out
  '';

  dontUnpack = true;
}

