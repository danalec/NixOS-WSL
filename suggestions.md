## Goals & Scope
- Capture a comprehensive, actionable plan to improve reliability, security, and maintainability.
- Cover Rust utilities, NixOS/WSL modules, CI/CD, documentation, and tests.
- Deliver changes in small, verifiable steps with clear ownership and rollback.

## Toolchain Alignment
- Choose a single Rust version across `utils/Cargo.toml` and dev shell.
- Option A: Keep `rust-version = "1.69"` and enforce that in dev shell; retain dependency caps.
- Option B: Bump to the current NixOS stable Rust and relax `<` caps (`clap`, `clap_lex`, `anstyle`, `anstyle-parse`), then update code if APIs changed.
- Add a note in docs about the chosen policy and its reasoning.

## Dependency Policy
- Run `cargo tree -d` to ensure no duplicate crates.
- Add `cargo-audit` to CI to flag vulnerable dependencies.
- Add `cargo-deny` to check licenses, duplicates, and bans.
- Add scheduled lockfile maintenance (already handled by Renovate) and document acceptance policy for minor/patch updates.
- Prefer dependencies with recent releases (<6 months) and document exceptions.

## Flake Inputs & Reproducibility
- Decide if `nixpkgs.url` should track `nixos-unstable` or pin `nixos-<current-stable>`.
- If stability is preferred, pin to stable and add a separate workflow job that builds against `unstable` for early detection.
- Document flake input policy and how updates are performed (Renovate PR flow).

## CI/CD Enhancements
- Add `clippy` check for `utils` (fail on warnings) and ensure `rustfmt --check` applies in CI.
- Add `cargo-audit` and `cargo-deny` workflows.
- Add Nix linters: `deadnix` (unused code) and `statix` (style) in checks.
- Keep GitHub Actions pinned by digest; let Renovate manage minor/patch automerge where safe.
- Publish mdBook docs as a job artifact and optionally to GitHub Pages.

## Security Hardening
- Provide an opt-in profile setting `security.sudo.wheelNeedsPassword = true` for shared/team environments.
- Clearly document implications of disabling Windows PATH interop and `.exe` binfmt registration.
- Confirm journald availability and persistence expectations under WSL; document limitations.
- Add docs about environment loading through `/etc/set-environment` and how to avoid unsafe overrides.

## WSL Integration Improvements
- Clarify `useWindowsDriver` in docs: prerequisites, supported GPUs, expected libs, troubleshooting.
- Add a simple runtime check to verify WSLg X11 socket mount and surface friendlier logs.
- Document networking choices: when to use WSL-managed `resolv.conf` vs `systemd-resolved`, including pitfalls.
- Explain Chrony config with PHC refclock; add troubleshooting for clock drift.

## Documentation Updates
- Create a new "Security Considerations" page covering sudo policy, PATH interop, systemd-only mode, and activation scripts.
- Expand "Installation" to include stable vs unstable flake guidance and versioning policy.
- Add a "Maintenance" page: how Renovate updates are reviewed and merged; how to run checks locally.
- Link code references to where behaviors live in modules and utils.

## Testing Enhancements
- Extend Pester tests:
  - Verify `wsl.conf` generation toggles (hosts, resolv.conf, interop).
  - Validate PATH splitting with mixed Windows paths and edge cases.
  - Check Chrony service presence and basic status.
  - Cover WSLg socket mount behavior.
- Add Rust unit tests for `split-path` covering empty segments, duplicated separators, and unusual characters.
- Consider lightweight Nix tests for module option interactions (where practical).

## Migration & Rollout
- Implement changes in small PRs:
  - CI additions (clippy, audit, deny, deadnix/statix).
  - Docs pages and cross-links.
  - Toolchain alignment.
- Gate riskier changes (rust-version bump, flake pin change) behind dedicated PRs, build/test across Windows + Linux.

## File Changes Outline
- `.github/workflows/`: add/modify jobs for `clippy`, `cargo-audit`, `cargo-deny`, `deadnix`, `statix`, docs build.
- `utils/Cargo.toml`: align `rust-version`, relax caps if bumping; update crates as needed.
- `flake.nix`: optionally pin `nixpkgs` to stable; add checks for Nix linters; expose docs package publication.
- `docs/src/`: add `security.md`, `maintenance.md`; expand `install.md` and `design.md`.
- `tests/`: add new Pester test files for `wsl.conf`, PATH, Chrony, WSLg.

## Verification Plan
- Run `nix flake check` and all CI jobs on PRs.
- Validate Windows Pester tests on `windows-latest` with WSL.
- Manually spot-check shell activation and PATH behavior inside WSL.
- Review Renovate PR behaviors after changes.

## Checklist
- [x] Nix checks for `deadnix` and `statix` added and wired
- [x] Clippy check added (`-D warnings`) and wired
- [x] Cargo audit/deny checks added and wired
- [x] Security and Maintenance docs present and aligned
- [x] Installation docs include stable vs unstable guidance
- [x] Design doc expanded (modules, systemd, interop, wsl.conf, WSLg)
- [x] Rust unit tests extended for `split-path`
- [x] Pester tests in place for wsl.conf, PATH, Chrony, WSLg
- [ ] Toolchain alignment PR (if bumping rust-version)
- [ ] Flake pin change PR (if adjusting channels)

Each item should be tracked via dedicated PRs; link PR numbers when opened.
