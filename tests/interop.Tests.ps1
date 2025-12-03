BeforeAll {
  . $PSScriptRoot/lib/lib.ps1
}

Describe "Interop .exe with additional binfmt" {
  BeforeAll {
    $distro = [Distro]::new()

    $temp = New-TemporaryFile
    @"
      { pkgs, lib, config, options, ... }:
      with lib; {
        imports = [
          <nixos-wsl/modules>
        ];

        wsl.enable = true;
        wsl.interop.register = true;

        boot.binfmt.registrations.Fake = {
          magicOrExtension = "F";
          fixBinary = true;
          wrapInterpreterInShell = false;
          interpreter = "${pkgs.coreutils}/bin/true";
        };
      }
"@ >  $temp
    $distro.InstallConfig($temp, "switch")
    Remove-Item $temp
  }

  It "should run Windows cmd.exe" {
    $out = $distro.Launch("cmd.exe /c echo HELLO-WSL") | Select-Object -Last 1
    $out | Should -BeExactly "HELLO-WSL"
    $LASTEXITCODE | Should -Be 0
  }

  AfterAll {
    $distro.Uninstall()
  }
}
