{ runCommand, cargo, clippy, ... }:
runCommand "check-clippy" { nativeBuildInputs = [ cargo clippy ]; } ''
  cargo clippy --manifest-path=${./../utils}/Cargo.toml -- -D warnings
  touch $out
''

