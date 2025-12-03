# Maintenance Guidelines

This document describes how to maintain NixOS-WSL, including dependency updates, CI/CD management, and development workflows.

## Flake Inputs and Updates

### Nixpkgs Pinning Policy

NixOS-WSL pins `nixpkgs` to the current stable release (`nixos-24.11`) for reproducibility and stability. This ensures:

- Predictable behavior across builds
- Compatibility with stable NixOS systems
- Reduced risk of breaking changes

Updates are managed through Renovate, which creates pull requests for:
- New stable releases
- Security updates
- Critical bug fixes

### Review Process for Updates

When reviewing Renovate PRs:

1. **Check the changelog** for breaking changes
2. **Verify CI passes** on the PR
3. **Test locally** if the update affects core functionality
4. **Consider the impact** on existing users
5. **Document any required changes** in the PR description

### Testing Against Unstable

While we pin to stable, we recommend testing against `nixos-unstable` periodically:

```bash
# Test build with unstable
nix build github:NixOS/nixpkgs/nixos-unstable#nixos-wsl
```

This helps identify potential issues before the next stable release.

## Rust Toolchain Management

### Version Alignment

The Rust toolchain is aligned with NixOS stable:

- `rust-version` in `utils/Cargo.toml` matches the stable channel
- Dependencies are updated to versions compatible with this Rust version
- CI enforces this alignment through `clippy` and `rustfmt` checks

### Dependency Updates

Rust dependencies are managed through:

1. **Cargo.lock**: Committed to ensure reproducible builds
2. **Renovate**: Creates PRs for dependency updates
3. **cargo-audit**: Checks for security vulnerabilities
4. **cargo-deny**: Validates licenses and prevents duplicates

### Review Criteria for Rust Updates

When reviewing Rust dependency updates:

- **Check for API changes** that might break the build
- **Verify security fixes** are applied promptly
- **Ensure license compatibility** with the project
- **Test the utilities** still function correctly
- **Review the changelog** for any behavioral changes

## CI/CD Maintenance

### GitHub Actions

All GitHub Actions are:

- **Pinned by digest** for security (not by tag)
- **Updated by Renovate** for patch/minor versions
- **Tested in PRs** before merging

### Required Checks

The following checks must pass before merging:

- ✅ `nixpkgs-fmt`: Nix code formatting
- ✅ `rustfmt`: Rust code formatting  
- ✅ `clippy`: Rust linting (warnings as errors)
- ✅ `cargo-audit`: Security vulnerability scan
- ✅ `cargo-deny`: License and duplicate validation
- ✅ `deadnix`: Dead code detection
- ✅ `statix`: Nix style linting
- ✅ `side-effects`: Build purity validation
- ✅ `username`: Configuration validation

### Test Suite

The test suite includes:

- **PowerShell/Pester tests**: Run on Windows with WSL
- **Basic functionality tests**: Core WSL operations
- **Systemd integration tests**: Service management
- **Docker compatibility tests**: Container runtime
- **Shell configuration tests**: Environment setup

## Development Workflow

### Local Development

Set up your development environment:

```bash
# Enable direnv (if installed)
direnv allow

# Or manually enter the dev shell
nix develop

# Run all checks
nix flake check

# Build specific components
nix build .#utils
nix build .#docs
```

### Code Quality

Before submitting PRs:

1. **Format code**: `nixpkgs-fmt .` for Nix, `cargo fmt` for Rust
2. **Run linting**: `cargo clippy -- -D warnings` for Rust
3. **Check for issues**: `deadnix .` and `statix check .`
4. **Test locally**: Build and test your changes
5. **Update documentation**: If adding features or changing behavior

### Testing Changes

Test your changes thoroughly:

```bash
# Build the tarball
nix build

# Test with a local WSL instance (if on Windows)
wsl --import test-nixos ./test ./result

# Run the test suite (if on Windows with WSL)
Invoke-Pester tests/
```

## Documentation Maintenance

### Documentation Standards

Documentation should:

- **Be accurate**: Reflect current behavior
- **Be complete**: Cover all major features
- **Be clear**: Use simple language and examples
- **Be consistent**: Follow the established style
- **Be cross-referenced**: Link to related topics

### Updating Documentation

When making changes:

1. **Update relevant docs**: Don't let documentation become stale
2. **Add examples**: Show practical usage
3. **Update SUMMARY.md**: If adding new pages
4. **Test locally**: Build the docs to verify formatting
5. **Review changes**: Ensure accuracy and completeness

### Documentation Build

Build and preview documentation:

```bash
nix build .#docs
# Open result/index.html in your browser
```

## Release Process

### Version Management

- Versions are managed through git tags
- The VERSION file contains the current version
- Releases are created automatically on tag push
- Artifacts include the WSL tarball and checksums

### Release Checklist

Before creating a release:

1. ✅ All CI checks pass on main branch
2. ✅ Documentation is up to date
3. ✅ CHANGELOG is updated (if maintained)
4. ✅ Version is bumped appropriately
5. ✅ Test the release build locally

### Post-Release

After release:

1. **Monitor for issues**: Check GitHub issues and discussions
2. **Update downstream**: Notify dependent projects if applicable
3. **Document lessons learned**: Note any issues for future releases

## Security Maintenance

### Security Updates

Security updates are prioritized:

- **Critical vulnerabilities**: Immediate attention and release
- **High severity**: Addressed in next release cycle
- **Medium/Low**: Addressed as part of regular maintenance

### Security Scanning

Automated security scanning includes:

- **cargo-audit**: Rust dependency vulnerabilities
- **GitHub Security Advisories**: Automated scanning
- **Dependency updates**: Via Renovate

### Reporting Security Issues

Security issues should be reported privately through GitHub Security Advisories when possible, or via email to maintainers for critical issues.

## Community and Support

### Issue Management

Issues are managed through GitHub:

- **Bug reports**: Verified and reproduced
- **Feature requests**: Evaluated for alignment with project goals
- **Questions**: Directed to appropriate documentation or discussions
- **Security issues**: Handled privately when appropriate

### Community Guidelines

The project follows these principles:

- **Be welcoming**: Help newcomers learn
- **Be constructive**: Provide actionable feedback
- **Be patient**: Complex issues take time to resolve
- **Be respectful**: Maintain professional discourse

## Monitoring and Metrics

### Build Health

Monitor build health through:

- **CI success rate**: Track over time
- **Build duration**: Watch for performance regressions
- **Test coverage**: Maintain adequate test coverage
- **Dependency freshness**: Keep dependencies reasonably current

### Performance

Track performance metrics:

- **Build times**: Monitor for regressions
- **Test execution**: Keep tests reasonably fast
- **Documentation build**: Ensure docs build quickly
- **Tarball size**: Watch for unexpected growth
