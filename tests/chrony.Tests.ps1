BeforeAll {
  . $PSScriptRoot/lib/lib.ps1
}

Describe "Chrony Service" {
  BeforeAll {
    $distro = [Distro]::new()
  }

  It "should have chrony service enabled" {
    $result = $distro.Launch("systemctl is-enabled chronyd")
    $LASTEXITCODE | Should -Be 0
    $result | Select-Object -Last 1 | Should -Be "enabled"
  }

  It "should have chrony service running" {
    $result = $distro.Launch("systemctl is-active chronyd")
    $LASTEXITCODE | Should -Be 0
    $result | Select-Object -Last 1 | Should -Be "active"
  }

  It "should have chrony configuration file" {
    $result = $distro.Launch("test -f /etc/chrony.conf")
    $LASTEXITCODE | Should -Be 0
  }

  It "should have PHC refclock configured" {
    $result = $distro.Launch("grep -q 'refclock PHC' /etc/chrony.conf")
    $LASTEXITCODE | Should -Be 0
  }

  It "should have correct chrony binary location" {
    $result = $distro.Launch("which chronyd")
    $LASTEXITCODE | Should -Be 0
    $result | Select-Object -Last 1 | Should -Be "/run/current-system/sw/bin/chronyd"
  }

  It "should handle time synchronization" {
    # Give chrony a moment to stabilize
    Start-Sleep 5

    $result = $distro.Launch("chronyc tracking")
    $LASTEXITCODE | Should -Be 0

    # Should show some tracking information
    $output = $result -join "`n"
    $output | Should -Match "Reference ID"
    $output | Should -Match "Stratum"
  }

  AfterAll {
    $distro.Uninstall()
  }
}
