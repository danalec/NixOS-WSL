BeforeAll {
  . $PSScriptRoot/lib/lib.ps1
}

Describe "WSL Configuration" {
  BeforeAll {
    $distro = [Distro]::new()
  }

  It "should have wsl.conf generated with correct defaults" {
    $result = $distro.Launch("cat /etc/wsl.conf")
    $LASTEXITCODE | Should -Be 0

    # Check for expected sections
    $config = $result -join "`n"
    $config | Should -Match "\[boot\]"
    $config | Should -Match "systemd=true"
    $config | Should -Match "\[interop\]"
    $config | Should -Match "enabled=true"
  }

  It "should have network configuration in wsl.conf" {
    $result = $distro.Launch("cat /etc/wsl.conf")
    $LASTEXITCODE | Should -Be 0

    $config = $result -join "`n"
    $config | Should -Match "\[network\]"
    $config | Should -Match "generateHosts=true"
    $config | Should -Match "generateResolvConf=true"
  }

  It "should have automount configuration in wsl.conf" {
    $result = $distro.Launch("cat /etc/wsl.conf")
    $LASTEXITCODE | Should -Be 0

    $config = $result -join "`n"
    $config | Should -Match "\[automount\]"
    $config | Should -Match "enabled=true"
    $config | Should -Match "root=/mnt"
  }

  It "should have interop configuration in wsl.conf" {
    $result = $distro.Launch("cat /etc/wsl.conf")
    $LASTEXITCODE | Should -Be 0

    $config = $result -join "`n"
    $config | Should -Match "\[interop\]"
    $config | Should -Match "enabled=true"
    $config | Should -Match "appendWindowsPath=true"
  }

  AfterAll {
    $distro.Uninstall()
  }
}
