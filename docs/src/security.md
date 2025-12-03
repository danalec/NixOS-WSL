# Security Considerations

This page outlines security-related aspects of NixOS-WSL and best practices for secure deployments.

## Sudo Configuration

By default, NixOS-WSL configures `security.sudo.wheelNeedsPassword = false` to allow passwordless sudo for the default user. This is convenient for development but may not be appropriate for shared or production environments.

### Hardening Sudo

To require passwords for sudo, set in your configuration:

```nix
{
  security.sudo.wheelNeedsPassword = true;
}
```

This ensures users must authenticate before gaining elevated privileges.

## Windows PATH Interop

The `wsl.interop.appendWindowsPath` option (enabled by default) includes Windows system paths in the WSL PATH. While convenient, this can introduce security considerations:

- Windows executables can be invoked from WSL
- PATH pollution may lead to unexpected binary resolution
- Consider disabling in security-sensitive environments:

```nix
{
  wsl.interop.appendWindowsPath = false;
}
```

## Binary Format Registration

WSL's interop system registers a binfmt handler for Windows executables. The module ensures proper registration, but be aware:

- Running Windows executables from WSL may bypass some Linux security controls
- Consider the security implications of cross-platform execution
- Review file permissions and executable bits carefully

## Network Configuration

### DNS Resolution

By default, WSL manages `/etc/resolv.conf`. If you disable this (`wsl.wslConf.network.generateResolvConf = false`), ensure you have alternative DNS configuration to prevent resolution issues.

### Hostname Generation

WSL can manage `/etc/hosts` generation. If disabled, ensure proper hostname resolution for services that depend on it.

## Systemd-Only Mode

The module enforces systemd-only operation (`wsl.wslConf.boot.systemd = true`). This is required for:

- Proper service management
- Security service isolation
- Consistent system behavior

Disabling systemd is strongly discouraged and will break core functionality.

## Environment Loading

The shell wrapper loads environment from `/etc/set-environment`. This file is generated during NixOS activation and contains system-wide environment variables. Be cautious when modifying this mechanism as it affects all user sessions.

## File System Considerations

### /bin Population

The module populates `/bin` with essential binaries. While convenient, this creates a writable `/bin` directory. In high-security environments, consider:

- Using absolute paths to Nix store binaries
- Leveraging NixOS's declarative approach over imperative /bin modifications

### Windows Driver Libraries

When `wsl.useWindowsDriver` is enabled, Windows OpenGL libraries are symlinked into the NixOS environment. These libraries:

- Originate from the Windows host
- May have different security properties than native Linux libraries
- Are essential for GPU acceleration but should be understood in security contexts

## Activation Scripts

System activation scripts run with elevated privileges during boot. The module includes scripts for:

- Setting up /usr/share directories
- Populating /bin with essential tools
- Configuring WSL-specific mounts

These scripts are part of the NixOS module system and are reproducible, but understand they modify system state during activation.

## Logging and Auditing

- System logs are available via `journalctl`
- WSL-specific messages may appear in Windows Event Viewer
- Consider log retention policies for security auditing
- The systemd journal is ephemeral by default in WSL environments

## Best Practices

1. **Regular Updates**: Keep NixOS-WSL and underlying NixOS updated
2. **Minimal Configuration**: Only enable features you need
3. **Review Options**: Understand security implications of each WSL option
4. **Network Segmentation**: Consider WSL networking modes for isolation
5. **Backup Configuration**: Maintain version-controlled configuration for rollback

## Reporting Security Issues

Security issues should be reported through the project's GitHub repository. Include:

- Detailed reproduction steps
- Expected vs actual behavior
- Configuration details (sanitized)
- Impact assessment
