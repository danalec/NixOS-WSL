# WSLg and Graphics

This guide explains GPU/graphics integration under WSLg and how NixOS-WSL wires it up.

## Prerequisites

- WSLg enabled on Windows
- A supported GPU and recent Windows drivers

## Enabling Windows Driver Libraries

Set:

```nix
{
  wsl.useWindowsDriver = true;
}
```

When enabled, NixOS-WSL links required Windows OpenGL/CUDA/D3D libraries into the environment. See the implementation in `modules/wsl-distro.nix:80-107`.

## WSLg X11 Socket Mount

The module ensures the WSLg X11 socket is available even if `/tmp` is re-mounted. See `modules/wsl-distro.nix:121-144`.

Verification:

```sh
ls -l /tmp/.X11-unix/X0
```

If missing, confirm WSLg is active and that `/mnt/wslg/.X11-unix/X0` exists.

## Troubleshooting

- Reboot the WSL distro: `wsl --terminate <Name>` then relaunch
- Confirm GPU acceleration is enabled: `glxinfo | rg -i rendering` (ripgrep is preferred per project policy)
- Ensure Windows drivers are up to date

## References

- Libraries symlink handling and graphics enablement: `modules/wsl-distro.nix:80-107`
- Socket mount and migration unit: `modules/wsl-distro.nix:121-144`

