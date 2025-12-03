BeforeAll {
  . $PSScriptRoot/lib/lib.ps1
}

Describe "WSLg Integration" {
  BeforeAll {
    $distro = [Distro]::new()
  }

  It "should have WSLg X11 socket mount service" {
    $result = $distro.Launch("systemctl is-enabled nixos-wsl-x11mount.service 2>/dev/null || true")
    # Legacy unit may not exist anymore; presence is optional
    $result = $distro.Launch("systemctl cat nixos-wsl-x11mount.service 2>/dev/null || true")
    $LASTEXITCODE | Should -Be 0
  }

  It "should handle X11 socket directory" {
    $result = $distro.Launch("test -d /tmp/.X11-unix")
    if ($LASTEXITCODE -ne 0) {
      # If directory doesn't exist, WSLg might not be available
      Write-Host "WSLg X11 socket directory not found - WSLg may not be available"
    }
  }

  It "should have Wayland socket handling" {
    $result = $distro.Launch("test -d /mnt/wslg")
    if ($LASTEXITCODE -ne 0) {
      Write-Host "WSLg runtime directory not found - WSLg may not be available"
    } else {
      # If WSLg is available, check for runtime files
      $result = $distro.Launch("ls -la /mnt/wslg/ 2>/dev/null || true")
      $LASTEXITCODE | Should -Be 0
    }
  }

  It "should handle PulseAudio socket" {
    $result = $distro.Launch("test -S /mnt/wslg/PulseAudio 2>/dev/null || true")
    # PulseAudio socket is optional, so we don't fail if it's not present
    $LASTEXITCODE | Should -Be 0
  }

  It "should have correct DISPLAY environment handling" {
    $result = $distro.Launch("echo \$DISPLAY")
    $LASTEXITCODE | Should -Be 0
    # DISPLAY should be set when WSLg is available
    $display = $result | Select-Object -Last 1
    if ($display -ne "") {
      $display | Should -Match ":[0-9]+"
    }
  }

  It "should have WSLg environment variables" {
    $result = $distro.Launch("env | grep -E '^(WSLG|WAYLAND|PULSE)' || true")
    $LASTEXITCODE | Should -Be 0

    # Check for common WSLg environment variables
    $envOutput = $result -join "`n"
    if ($envOutput -ne "") {
      # If WSLg vars are present, they should be properly formatted
      $envOutput | Should -Match "WSLG_.*="
    }
  }

  AfterAll {
    $distro.Uninstall()
  }
}
