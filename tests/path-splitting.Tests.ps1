BeforeAll {
  . $PSScriptRoot/lib/lib.ps1
}

Describe "PATH Splitting" {
  BeforeAll {
    $distro = [Distro]::new()
  }

  It "should have split-path utility available" {
    $result = $distro.Launch("which split-path")
    $LASTEXITCODE | Should -Be 0
    $result | Select-Object -Last 1 | Should -Match "/bin/split-path"
  }

  It "should split Windows paths from Linux paths" {
    # Test with mixed paths
    $testPath = "/usr/local/bin:/mnt/c/Windows/System32:/usr/bin:/mnt/d/Program Files"
    $result = $distro.Launch("PATH='$testPath' split-path --automount-root=/mnt")
    $LASTEXITCODE | Should -Be 0

    # Should separate native and Windows paths
    $output = $result -join "`n"
    $output | Should -Match "export PATH='/usr/local/bin:/usr/bin'"
    $output | Should -Match "export WSLPATH='/mnt/c/Windows/System32:/mnt/d/Program Files'"
  }

  It "should handle empty segments gracefully" {
    $testPath = "/usr/bin::/usr/local/bin:"
    $result = $distro.Launch("PATH='$testPath' split-path --automount-root=/mnt")
    $LASTEXITCODE | Should -Be 0

    $output = $result -join "`n"
    $output | Should -Match "export PATH="
  }

  It "should handle paths with spaces and special characters" {
    $testPath = "/usr/bin:/mnt/c/Program Files (x86)/App:/usr/local/bin"
    $result = $distro.Launch("PATH='$testPath' split-path --automount-root=/mnt")
    $LASTEXITCODE | Should -Be 0

    $output = $result -join "`n"
    $output | Should -Match "export PATH='/usr/bin:/usr/local/bin'"
    $output | Should -Match "export WSLPATH='/mnt/c/Program Files \(x86\)/App'"
  }

  It "should handle include-interop option" {
    $testPath = "/usr/bin:/mnt/c/Windows:/usr/local/bin"
    $result = $distro.Launch("PATH='$testPath' split-path --automount-root=/mnt --include-interop")
    $LASTEXITCODE | Should -Be 0

    $output = $result -join "`n"
    # With --include-interop, Windows paths should be included in PATH
    $output | Should -Match "export PATH='/usr/bin:/usr/local/bin:/mnt/c/Windows'"
    $output | Should -Match "export WSLPATH='/mnt/c/Windows'"
  }

  AfterAll {
    $distro.Uninstall()
  }
}
