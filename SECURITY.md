# Security Policy

## Supported Versions
- The current main branch and the latest tagged release are supported for security fixes.

## Reporting a Vulnerability
- Please open a private advisory on GitHub Security Advisories or email the maintainers. Provide a clear description, reproduction steps, affected components, and impact.

## Disclosure Process
- We triage within a reasonable timeframe, confirm impact, prepare a fix, and publish a patch release with notes. Credits to reporters are included when appropriate.

## Configuration Considerations
- WSL default user has passwordless sudo. For shared/team machines, enable `security.sudo.wheelNeedsPassword = true` and document team policies.
- Windows PATH interop and `.exe` binfmt can affect tooling security posture. Disable only with clear understanding of trade‑offs.
- Journald availability under WSL is limited; avoid relying on persistent logs for sensitive auditing.

## Dependencies
- Automated checks run `cargo audit` and `cargo deny`. Vulnerabilities or license issues are fixed promptly. Renovate maintains lockfiles and pins.
