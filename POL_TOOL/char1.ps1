$userBinName = "char1"
$shortcutPath = "D:\Windower4\Windower (Vanilla).lnk"
$proxyPath = "D:\Windower4\PolProxy.exe"
$silmarilPath = "D:\Windower4\addons\Silmaril\Silmaril.exe"

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
        "-ProxyPath", "`"$proxyPath`"",
        "-silmarilPath", "`"$silmarilPath`""
    )
} else {
    Write-Host "Sibling script not found: $siblingScriptPath"
}
