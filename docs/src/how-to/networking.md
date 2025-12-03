# Networking in WSL

This guide explains DNS/hosts behavior and choices between WSL-managed files and systemd-resolved.

## DNS (`/etc/resolv.conf`)

- By default, WSL manages `/etc/resolv.conf`.
- To rely on WSL-managed DNS, keep `wsl.wslConf.network.generateResolvConf = true` (default).
- If you set `wsl.wslConf.network.generateResolvConf = false`, configure `networking.nameservers` or enable `services.resolved`.

Warnings are surfaced when combinations may be unsafe or surprising; see `modules/wsl-distro.nix:233-243`.

## Hosts (`/etc/hosts`)

- WSL can generate `/etc/hosts`. When `wsl.wslConf.network.generateHosts = true`, module disables NixOS management of `hosts` to avoid conflicts (`modules/wsl-distro.nix:109-118`).

## Recommended Setups

- Development defaults: leave WSL-managed DNS/hosts enabled; do not enable `services.resolved`.
- Custom DNS: set `wsl.wslConf.network.generateResolvConf = false` and provide `networking.nameservers` or enable `services.resolved`.

## Verification

```sh
cat /etc/resolv.conf
cat /etc/hosts
```

## References

- DNS/hosts toggles: `modules/wsl-distro.nix:109-118`
- Safety warnings: `modules/wsl-distro.nix:233-243`

