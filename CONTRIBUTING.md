# Contributing

## Development Setup
- Use the Nix dev shell (`nix develop`) which provides Rust toolchain, linters, and utilities.
- Build docs with `nix build .#docs` and preview via generated artifacts.

## Coding Standards
- Rust: clippy clean (`-D warnings`) and rustfmt formatted.
- Nix: deadnix and statix must pass; format with `nixpkgs-fmt`.
- Shell: prefer `shfmt` formatting and POSIX‑compatible scripts where practical.

## CI Requirements
- Enhanced checks include clippy, cargo audit/deny, deadnix, statix. All must pass.
- Tarball builds for stable; optional unstable build detects upstream changes.

## Module Changes
- Preserve WSL integration guarantees (systemd native, interop behavior, networking defaults).
- Document configuration changes in `docs/src` and update examples.

## Reporting Issues and PRs
- Include reproduction steps, environment details (WSL version, Windows build), and expected/actual behavior.
- Keep PRs small and focused; link to tracking checklist items where applicable.
