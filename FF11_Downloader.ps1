if (-not (Get-Command aria2c -ErrorAction SilentlyContinue)) {
    Write-Host "Aria2 not found. Installing..."
    winget install -e --id aria2
}

function Test-Admin {
    $isAdmin = [System.Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544'
    if (-not $isAdmin) {
        Write-Host "This script requires Administrator privileges. Restarting as Administrator..."
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
}

$global:regionLower = $null
$global:regionUpper = $null

function Get-Region {
    if ($global:regionLower -and $global:regionUpper) {
        return @($global:regionLower, $global:regionUpper)
    }

    while ($true) {
        Write-Host "`nSelect Region:"
        Write-Host "1 - North America (NA)"
        Write-Host "2 - Europe (EU)"
        Write-Host "3 - Japan (JP)"
        $regionChoice = Read-Host "`nEnter your choice"

        switch ($regionChoice.ToLower()) {
            "1" {
                $global:regionLower = "us"
                $global:regionUpper = "US"
                return @($global:regionLower, $global:regionUpper)
            }
            "2" {
                $global:regionLower = "eu"
                $global:regionUpper = "EU"
                return @($global:regionLower, $global:regionUpper)
            }
            "3" {
                $global:regionLower = "jp"
                $global:regionUpper = "JP"
                return @($global:regionLower, $global:regionUpper)
            }
            default {
                Write-Host " Invalid choice, please enter 1, 2, 3, or Q."
            }
        }
    }
}

function Download {
    $regionValues = Get-Region
    $regionLower = $regionValues[0]
    $regionUpper = $regionValues[1]

    $urls = @(
        "https://gdl.square-enix.com/ffxi/download/$regionLower/FFXIFullSetup_$regionUpper.part1.exe",
        "https://gdl.square-enix.com/ffxi/download/$regionLower/FFXIFullSetup_$regionUpper.part2.rar",
        "https://gdl.square-enix.com/ffxi/download/$regionLower/FFXIFullSetup_$regionUpper.part3.rar",
        "https://gdl.square-enix.com/ffxi/download/$regionLower/FFXIFullSetup_$regionUpper.part4.rar",
        "https://gdl.square-enix.com/ffxi/download/$regionLower/FFXIFullSetup_$regionUpper.part5.rar"
    )

    $scriptDirectory = $PSScriptRoot
    $downloadPath = Join-Path -Path $scriptDirectory -ChildPath "FF11-Setup"

    if (-not (Test-Path $downloadPath)) {
        Write-Host "Creating download directory: $downloadPath"
        New-Item -ItemType Directory -Path $downloadPath
    }

    foreach ($url in $urls) {
        $fileName = [System.IO.Path]::GetFileName($url)
        $filePath = Join-Path -Path $downloadPath -ChildPath $fileName

        if (Test-Path $filePath) {
            Write-Host "$fileName already exists, skipping..."
            continue
        }

        Write-Host "Downloading $fileName..."
        aria2c --file-allocation=none -x 16 -s 16 -d "$downloadPath" -o "$fileName" "$url"
    }
}

function Extract {
    $scriptDirectory = $PSScriptRoot
    $downloadPath = Join-Path -Path $scriptDirectory -ChildPath "FF11-Setup"
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

Test-Admin;

$downloadCompleted = $false
$extractionCompleted = $false

while ($true) {
    Write-Host "`nFFXI Setup Downloader"
    Write-Host "Script created by Sevu @ Bahamut."
    Write-Host "This script will download the setup files and store them in the 'FF11-Setup' folder."

    Write-Host "`nOptions:"
    Write-Host "1 - Download only"
    Write-Host "2 - Download and unpack (extract) setup files"
    Write-Host "Q - Quit"

    $choice = Read-Host "`nSelect an option"

    switch ($choice) {
        "1" {
            Write-Host "Starting download..."
            Download
            $downloadCompleted = $true
        }
        "2" {
            Write-Host "Starting download and extraction..."
            Download
            $downloadCompleted = $true
            Extract
            $extractionCompleted = $true
        }
        "Q" {
            Write-Host "Quitting..."
            exit
        }
        default {
            Write-Host "Invalid option, please try again."
        }
    }

    if ($downloadCompleted -or $extractionCompleted) {
        break
    }
}

if ($downloadCompleted -and $extractionCompleted) {
    Write-Host "`nDownload and extraction completed successfully!"
} elseif ($downloadCompleted) {
    Write-Host "`nDownload completed successfully!"
} elseif ($extractionCompleted) {
    Write-Host "`nDownload and unpack (extract) setup files completed successfully!"
}

Write-Host "`nPress Enter to exit..."
Read-Host
