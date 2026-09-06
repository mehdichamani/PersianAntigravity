<#
.SYNOPSIS
    Antigravity IDE Proxy Launcher (Windows)
.DESCRIPTION
    Detects active system proxy settings from the Windows Registry or environment variables,
    injects them into HTTP_PROXY / HTTPS_PROXY / ALL_PROXY, and launches Antigravity IDE.
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\antigravity-proxy.ps1
    powershell -ExecutionPolicy Bypass -File .\antigravity-proxy.ps1 "C:\my-project"
#>

[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$IdeArgs
)

# 1. Close any running Antigravity IDE instances
Stop-Process -Name "Antigravity IDE" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "antigravity" -Force -ErrorAction SilentlyContinue

# 2. Locate Antigravity IDE executable (antigravity-ide.cmd or Antigravity IDE.exe)
$targetBin = $null

# Check PATH
$cmd = Get-Command "antigravity-ide" -ErrorAction SilentlyContinue
if ($cmd -and $cmd.Source) {
    $targetBin = $cmd.Source
}

# Fallback to standard installation paths
if (-not $targetBin -or -not (Test-Path -LiteralPath $targetBin)) {
    $binCandidates = @(
        "$env:LOCALAPPDATA\Programs\Antigravity IDE\bin\antigravity-ide.cmd",
        "$env:LOCALAPPDATA\Programs\Antigravity IDE\Antigravity IDE.exe",
        "$env:ProgramFiles\Antigravity IDE\bin\antigravity-ide.cmd",
        "$env:ProgramFiles\Antigravity IDE\Antigravity IDE.exe",
        "$env:ProgramFiles(x86)\Antigravity IDE\bin\antigravity-ide.cmd",
        "$env:ProgramFiles(x86)\Antigravity IDE\Antigravity IDE.exe",
        "$env:USERPROFILE\AppData\Local\Programs\Antigravity IDE\bin\antigravity-ide.cmd"
    )
    foreach ($cand in $binCandidates) {
        if (Test-Path -LiteralPath $cand) {
            $targetBin = $cand
            break
        }
    }
}

if (-not $targetBin) {
    Write-Error "Could not locate Antigravity IDE executable. Please ensure it is installed and in PATH."
    exit 1
}

# 3. Dynamically fetch system proxy from Windows Registry
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
$sysProxy = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue

$detectedProxy = $null

if ($sysProxy -and $sysProxy.ProxyEnable -eq 1 -and $sysProxy.ProxyServer) {
    $proxyServer = [string]$sysProxy.ProxyServer

    if ($proxyServer -match "http=([^;]+)") {
        $httpProxy = $Matches[1]
    } else {
        $httpProxy = $proxyServer
    }

    if ($proxyServer -match "https=([^;]+)") {
        $httpsProxy = $Matches[1]
    } else {
        $httpsProxy = $httpProxy
    }

    if ($httpProxy -notmatch "^https?://") { $httpProxy = "http://$httpProxy" }
    if ($httpsProxy -notmatch "^https?://") { $httpsProxy = "http://$httpsProxy" }

    $detectedProxy = $httpProxy

    $env:HTTP_PROXY  = $httpProxy
    $env:HTTPS_PROXY = $httpsProxy
    $env:http_proxy  = $httpProxy
    $env:https_proxy = $httpsProxy
    $env:ALL_PROXY   = $httpProxy
    $env:all_proxy   = $httpProxy

    if ($sysProxy.ProxyOverride) {
        $bypass = [string]$sysProxy.ProxyOverride -replace '<local>', 'localhost' -replace ';', ','
        $env:no_proxy = $bypass
        $env:NO_PROXY = $bypass
    } else {
        $defaultBypass = "localhost,127.0.0.1,::1,192.168.0.0/16,10.0.0.0/8"
        $env:no_proxy = $defaultBypass
        $env:NO_PROXY = $defaultBypass
    }
} else {
    # Check if environment already had proxies
    if ($env:HTTP_PROXY -or $env:http_proxy) {
        $detectedProxy = if ($env:HTTP_PROXY) { $env:HTTP_PROXY } else { $env:http_proxy }
    } else {
        Remove-Item env:HTTP_PROXY -ErrorAction SilentlyContinue
        Remove-Item env:HTTPS_PROXY -ErrorAction SilentlyContinue
        Remove-Item env:http_proxy -ErrorAction SilentlyContinue
        Remove-Item env:https_proxy -ErrorAction SilentlyContinue
        Remove-Item env:ALL_PROXY -ErrorAction SilentlyContinue
        Remove-Item env:all_proxy -ErrorAction SilentlyContinue
        Remove-Item env:no_proxy -ErrorAction SilentlyContinue
        Remove-Item env:NO_PROXY -ErrorAction SilentlyContinue
    }
}

# 4. Launch the IDE with optional arguments
if ($IdeArgs -and $IdeArgs.Count -gt 0) {
    Start-Process -FilePath $targetBin -ArgumentList $IdeArgs -WindowStyle Hidden
} else {
    Start-Process -FilePath $targetBin -WindowStyle Hidden
}
