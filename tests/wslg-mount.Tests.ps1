BeforeAll {
  . $PSScriptRoot/lib/lib.ps1
}

Describe "WSLg X11 mount behavior" {
  BeforeAll {
    $distro = [Distro]::new()
  }

  It "unit contains ConditionPathExists" {
    $unit = "tmp-.X11-unix-X0.mount"
    $text = $distro.Launch("systemctl cat $unit")
    ($text | Select-Object -Last 1) | Should -Match "ConditionPathExists=/mnt/wslg/.X11-unix/X0"
    $LASTEXITCODE | Should -Be 0
  }

  It "is inactive when socket is missing" {
    $exists = $distro.Launch("test -e /mnt/wslg/.X11-unix/X0 && echo yes || echo no") | Select-Object -Last 1
    $state = $distro.Launch("systemctl show -p ActiveState tmp-.X11-unix-X0.mount | cut -d= -f2") | Select-Object -Last 1
    if ($exists -eq "no") {
      $state | Should -Be "inactive"
    } else {
      # If the socket exists on host with WSLg, allow active state
      $state | Should -Match "active|activating"
    }
  }

  AfterAll {
    $distro.Uninstall()
  }
}
