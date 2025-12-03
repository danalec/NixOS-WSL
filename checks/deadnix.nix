{ runCommand, deadnix, ... }:
runCommand "check-deadnix" { nativeBuildInputs = [ deadnix ]; } ''
  deadnix --fail \
    --exclude docs \
    --exclude assets \
    --exclude tests \
    .
  touch $out
''

