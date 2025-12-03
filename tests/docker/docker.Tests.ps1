BeforeAll {
  . $PSScriptRoot/../lib/lib.ps1
}

Describe "Docker (native)" {
  BeforeAll {
    $distro = [Distro]::new()
    try {
      $distro.InstallConfig("$PSScriptRoot/docker-native.nix", "switch")
    }
    catch {
      $distro.Launch("sudo journalctl --no-pager -u docker.service")
      throw $_
    }
    $active = $distro.Launch("systemctl is-active docker.service") | Select-Object -Last 1
    $dockerAvailable = ($LASTEXITCODE -eq 0 -and $active -eq "active")
  }

  It "should be possible to run a docker container" {
    if (-not $dockerAvailable) { Write-Host "Docker not available, skipping"; return }
    $distro.Launch("docker run --rm -i hello-world")
    $LASTEXITCODE | Should -Be 0
  }

  It "should still be possible to run a docker container after a restart" {
    if (-not $dockerAvailable) { Write-Host "Docker not available, skipping"; return }
    $distro.Shutdown()
    $distro.Launch("docker run --rm -i hello-world")
    $LASTEXITCODE | Should -Be 0
  }

  It "should be possible to connect to the internet from a container" {
    if (-not $dockerAvailable) { Write-Host "Docker not available, skipping"; return }
    $distro.Launch("docker run --rm -i alpine wget -qO- http://www.msftconnecttest.com/connecttest.txt") | Select-Object -Last 1 | Should -BeExactly "Microsoft Connect Test"
    $LASTEXITCODE | Should -Be 0
  }

  It "should be possible to mount a volume from the host" {
    if (-not $dockerAvailable) { Write-Host "Docker not available, skipping"; return }
    $teststring = [guid]::NewGuid().ToString()

    $testdir = $distro.Launch("mktemp -d") | Select-Object -Last 1
    $testfilename = "testfile"
    $testfile = "${testdir}/${testfilename}"
    $distro.Launch("echo $teststring > $testfile")
    $distro.Launch("docker run --rm -i -v ${testdir}:/mnt alpine cat /mnt/${testfilename}") | Select-Object -Last 1 | Should -BeExactly $teststring
    $LASTEXITCODE | Should -Be 0
  }

  AfterAll {
    $distro.Uninstall()
  }
}
