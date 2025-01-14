param (
    [string]$userBinName,
    [string]$windowerPath,
    [string]$shortcutPath,
    [string]$proxyPath
)

if (-not ($windowerPath -or $shortcutPath)) {
    Write-Error "You must provide either the path to Windower or the path to a shortcut file."
    exit
}

if ($windowerPath) {
    if (-not (Test-Path $windowerPath -PathType Leaf)) {
        Write-Host "Windower.exe not found at '$windowerPath'."
        exit
    }
} elseif ($shortcutPath) {
    if (-not (Test-Path $shortcutPath -PathType Leaf)) {
        Write-Host "Shortcut file not found at '$shortcutPath'."
        exit
    }
}

if ($proxyPath) {
    $proxyName = [System.IO.Path]::GetFileNameWithoutExtension($proxyPath)
    $proxyProcess = Get-Process -Name $proxyName -ErrorAction SilentlyContinue
    if ($proxyProcess) {
        Write-Host "'$proxyName' is running."
    } else {
        try {
            Start-Process -FilePath $proxyPath -WindowStyle Hidden -ErrorAction SilentlyContinue
        }
        catch {
            Write-Host "$proxyName launch failed"
        }
    }
}

$binFile = "$PSScriptRoot\$userBinName.bin"
if (-not (Test-Path $binFile -PathType Leaf)) {
    Write-Host "File '$userBinName.bin' doesn't exist."
    exit
}

$loginBin = "$PSScriptRoot\login_w.bin"
if (Test-Path $loginBin -PathType Leaf) {
    Remove-Item $loginBin -Force
}

Copy-Item $binFile $loginBin -Force

if ($windowerPath) {
    Start-Process -FilePath $windowerPath
} elseif ($shortcutPath) {
    Invoke-Item $shortcutPath
}