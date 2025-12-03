{ runCommand, statix, ... }:
runCommand "check-statix" { nativeBuildInputs = [ statix ]; } ''
  statix check --ignore docs --ignore assets --ignore tests .
  touch $out
''

