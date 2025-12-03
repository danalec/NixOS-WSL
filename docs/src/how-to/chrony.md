# Chrony and Clock Stability

WSL has a unique clock model; NixOS-WSL configures Chrony to improve stability.

## Configuration

Chrony is enabled with a PHC refclock and a minimal setup. See `modules/wsl-distro.nix:219-231`.

Key options:

```nix
services.chrony = {
  enable = true;
  extraConfig = ''
    makestep 1.0 3
    leapsectz right/UTC
    refclock PHC /dev/ptp0 poll 3 dpoll -2 offset 0
  '';
  servers = [];
};
```

This avoids fighting WSL’s host time while correcting drift inside the distro.

## Verification

```sh
chronyc sources -v
systemctl status chrony.service
```

## Troubleshooting

- If drift persists, check dmesg for PHC/ptp device issues
- Confirm `chronyd` is active and not blocked by sandboxing

## References

- Chrony wiring: `modules/wsl-distro.nix:219-231`

