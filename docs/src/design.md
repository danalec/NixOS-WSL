# Design

## Module Overview

The WSL integration is implemented as a NixOS module set that wires together boot behavior, interop, environment handling, and packaging:

- `modules/default.nix` imports all WSL-specific modules and exposes a single entry module.
- `modules/wsl-distro.nix` defines core options and activation logic tailored for WSL.
- `modules/wsl-conf.nix` materializes `/etc/wsl.conf` from typed Nix options with sensible defaults.
- `modules/systemd/native` provides native systemd wiring and shell environment initialization.

## Systemd Boot Path

WSL requires system activation steps prior to launching systemd. A small utility (`systemd-shim`) runs activation scripts and then execs systemd. This ensures a reproducible, declarative boot sequence aligned with NixOS expectations.

Key behaviors:
- Activation populates required FHS paths (such as `/bin`) for compatibility with WSL internals.
- Boot sets up tempfiles and channel links so `nixos-rebuild` works out-of-the-box.

## Interop and PATH Handling

WSL interop mixes Windows paths (`/mnt/...`) into the environment. To keep behavior predictable:

- PATH entries are split into native and interop subsets using the `split-path` utility.
- Exports two variables:
  - `PATH` containing native Linux paths
  - `WSLPATH` containing Windows mount paths
- Optionally, interop paths can be re-included into `PATH` when explicitly enabled.

This approach reduces surprising resolution issues and makes interop explicit.

## wsl.conf Generation

The module emits `/etc/wsl.conf` based on Nix options mirroring Microsoft’s schema:

- `[boot]` enforces `systemd = true` for reliable service management.
- `[interop]` controls Windows executable handling and PATH appending.
- `[automount]` governs `/mnt` behavior and mount options.
- `[network]` manages hosts and resolv.conf generation.

Warnings are surfaced when combinations may be unsafe or surprising.

## WSLg and Graphics

When `useWindowsDriver` is enabled, required graphics libraries from the Windows host are linked into the WSL environment for GPU acceleration. WSLg sockets are mounted and validated at startup, and friendly logs are provided to aid troubleshooting.

## Packaging and Dev Experience

- Rust utilities are packaged via `rustPlatform.buildRustPackage` and exposed through the module for boot-time usage.
- The flake provides `packages.utils`, `packages.docs`, and a dev shell with Rust, mdBook, and Nix tooling.
- CI builds the WSL tarball, runs checks, executes Pester tests on Windows, validates against upstream tooling, and publishes documentation.
