$userBinName = "char1"
$shortcutPath = "D:\Windower4\Windower (Vanilla).lnk"
$proxyPath = "D:\Windower4\PolProxy.exe"

# Get the directory of the currently executing script
if (-not $PSScriptRoot) {
    Write-Error "Unable to determine script directory."
    exit 1
}

$currentScriptPath = $PSScriptRoot

$siblingScriptPath = Join-Path -Path $currentScriptPath -ChildPath "launch.ps1"

if (Test-Path $siblingScriptPath) {
    Start-Process powershell.exe -ArgumentList @(
        "-File", "`"$siblingScriptPath`"",
        "-UserBinName", $userBinName,
        "-ShortcutPath", "`"$shortcutPath`"",
        "-ProxyPath", "`"$proxyPath`""
    )
} else {
    Write-Host "Sibling script not found: $siblingScriptPath"
}
