if (-not (Get-Command aria2c -ErrorAction SilentlyContinue)) {
    Write-Host "Aria2 not found. Installing..."
    winget install -e --id aria2
}

function Test-Admin {
    $isAdmin = [System.Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544'
    if (-not $isAdmin) {
        Write-Host "This script requires Administrator privileges. Restarting as Administrator..."
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        return
    }
}

function Get-Region {
    while ($true) {
        Write-Host "`nFFXI Setup Downloader"
        Write-Host "Script created by Sevu @ Bahamut."
        Write-Host "This script will download the setup files and store them in the 'FF11-Setup' folder."
        Write-Host "`nWhich region do you want to download?"
        Write-Host "1 - North America (NA)"
        Write-Host "2 - Europe (EU)"
        Write-Host "3 - Japan (JP)"
        Write-Host "Q - Quit"

        $regionChoice = Read-Host "Enter your choice"

        switch ($regionChoice.ToLower()) {
            "1" { return @("us", "US") }
            "2" { return @("eu", "EU") }
            "3" { return @("jp", "JP") }
            "q" { exit }
            default { Write-Host "Invalid choice, please enter 1, 2, 3, or Q." }
        }
    }
}

function Download ($regionValues) {
    $regionLower = $regionValues[0]
    $regionUpper = $regionValues[1]

    $urls = @(
        "https://gdl.square-enix.com/ffxi/download/$regionLower/FFXIFullSetup_$regionUpper.part1.exe",
        "https://gdl.square-enix.com/ffxi/download/$regionLower/FFXIFullSetup_$regionUpper.part2.rar",
        "https://gdl.square-enix.com/ffxi/download/$regionLower/FFXIFullSetup_$regionUpper.part3.rar",
        "https://gdl.square-enix.com/ffxi/download/$regionLower/FFXIFullSetup_$regionUpper.part4.rar",
        "https://gdl.square-enix.com/ffxi/download/$regionLower/FFXIFullSetup_$regionUpper.part5.rar"
    )

    $downloadPath = Join-Path -Path $PSScriptRoot -ChildPath "FF11-Setup"

    if (-not (Test-Path $downloadPath)) {
        Write-Host "Creating download directory: $downloadPath"
        New-Item -ItemType Directory -Path $downloadPath | Out-Null
    }

    foreach ($url in $urls) {
        $fileName = [System.IO.Path]::GetFileName($url)
        $filePath = Join-Path -Path $downloadPath -ChildPath $fileName

        if (Test-Path $filePath) {
            Write-Host "$fileName already exists, skipping..."
            continue
        }

        Write-Host "Downloading $fileName..."
        Start-Process -NoNewWindow -Wait -FilePath "aria2c" -ArgumentList "--file-allocation=none -x 16 -s 16 -d `"$downloadPath`" -o `"$fileName`" `"$url`""
    }
}

function Extract {
    $downloadPath = Join-Path -Path $PSScriptRoot -ChildPath "FF11-Setup"
    $exeFiles = Get-ChildItem -Path $downloadPath -Filter "*.exe"

    if ($exeFiles.Count -eq 0) {
        Write-Host "No .exe files found in $downloadPath. Skipping extraction."
        return
    }

    foreach ($exeFile in $exeFiles) {
        Write-Host "Extracting $($exeFile.Name)..."
        
        try {
            Start-Process -FilePath $exeFile.FullName -ArgumentList "/S" -WorkingDirectory $downloadPath -Wait
            Write-Host "Extraction completed for $($exeFile.Name)."
        } catch {
            Write-Host "Failed to run $($exeFile.Name)."
        }
    }
}

Test-Admin

$region = Get-Region

while ($true) {
    Write-Host "`nOptions:"
    Write-Host "1 - Download only"
    Write-Host "2 - Download and extract"
    Write-Host "Q - Quit"

    $choice = Read-Host "Select an option"

    switch ($choice) {
        "1" {
            Write-Host "Starting download..."
            Download $region
        }
        "2" {
            Write-Host "Starting download and extraction..."
            Download $region
            Extract
            exit
        }
        "Q" {
            Write-Host "Quitting..."
            exit
        }
        default {
            Write-Host "Invalid option, please try again."
        }
    }
}
