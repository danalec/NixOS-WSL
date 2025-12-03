BeforeAll {
  . $PSScriptRoot/../lib/lib.ps1
}

Describe "Login Shell" {
  BeforeAll {
    $distro = [Distro]::new()
  }

  It "should start commands in a login shell" {
    Write-Host "> bash -lc 'shopt login_shell'"
    $output = $distro.Launch("bash -lc 'shopt login_shell'")
    $output | Select-Object -Last 1 | Should -Match "login_shell\s*on"
  }

  It "should be possible to install a configuration that uses home-manager session variables" {
    $distro.InstallConfig("$PSScriptRoot/session-variables.nix", "switch")
  }

  It "should have created the hm-session-vars.sh file" {
    $distro.Launch("test -f ~/.nix-profile/etc/profile.d/hm-session-vars.sh")
    $LASTEXITCODE | Should -Be 0
  }

  It "should be possible to access home manager sessionVariables in bash" {
    Write-Host "> echo `$TEST_VARIABLE"
    $output = $distro.Launch("bash -lc 'echo `$TEST_VARIABLE'")
    $output | Select-Object -Last 1 | Should -BeExactly "THISISATESTSTRING"

    Write-Host "> echo `$EDITOR"
    $output = $distro.Launch("bash -lc 'echo `$EDITOR'")
    $output | Select-Object -Last 1 | Should -BeExactly "vim"
  }

  AfterAll {
    $distro.Uninstall()
  }
}
