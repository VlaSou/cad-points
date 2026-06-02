#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [string]$SourcePath,
    [string]$DestinationRoot = [System.IO.Path]::Combine(
        [System.Environment]::GetFolderPath('ApplicationData'),
        'Autodesk',
        'ApplicationPlugins'
    )
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-BundleCandidate {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }

    $item = Get-Item -LiteralPath $Path
    if ($item.PSIsContainer -and $item.Name -ieq 'CadPoints.bundle') {
        if (Test-Path -LiteralPath (Join-Path $item.FullName 'PackageContents.xml')) {
            return $item.FullName
        }
    }

    if ($item.PSIsContainer) {
        $bundle = Join-Path $item.FullName 'CadPoints.bundle'
        if (Test-Path -LiteralPath (Join-Path $bundle 'PackageContents.xml')) {
            return (Get-Item -LiteralPath $bundle).FullName
        }
    }

    return $null
}

function Get-SourceCandidates {
    param(
        [string]$RequestedPath
    )

    $candidates = New-Object System.Collections.Generic.List[string]

    if ($RequestedPath) {
        $candidates.Add($RequestedPath)
    }

    $scriptRoot = $PSScriptRoot
    if ($scriptRoot) {
        $candidates.Add((Join-Path $scriptRoot '..\dist\CadPoints.bundle'))
        $candidates.Add((Join-Path $scriptRoot '..\src\CadPoints.bundle'))
        $candidates.Add((Join-Path $scriptRoot '..\CadPoints.bundle'))
    }

    $currentLocation = (Get-Location).Path
    $candidates.Add((Join-Path $currentLocation 'CadPoints.bundle'))
    $candidates.Add((Join-Path $currentLocation 'dist\CadPoints.bundle'))
    $candidates.Add((Join-Path $currentLocation 'src\CadPoints.bundle'))

    return $candidates
}

function Resolve-BundleSource {
    param(
        [string]$RequestedPath
    )

    foreach ($candidate in Get-SourceCandidates -RequestedPath $RequestedPath) {
        $resolved = Resolve-BundleCandidate -Path $candidate
        if ($resolved) {
            return $resolved
        }
    }

    throw "Nenalezen zdrojový CadPoints.bundle. Zkus skript spustit z kořene repozitáře nebo předej parametr -SourcePath."
}

function Remove-ExistingBundle {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BundlePath
    )

    if (Test-Path -LiteralPath $BundlePath) {
        Remove-Item -LiteralPath $BundlePath -Recurse -Force
    }
}

$sourceBundle = Resolve-BundleSource -RequestedPath $SourcePath
$destinationRoot = [System.IO.Path]::GetFullPath($DestinationRoot)
$destinationBundle = Join-Path $destinationRoot 'CadPoints.bundle'

New-Item -ItemType Directory -Path $destinationRoot -Force | Out-Null
Remove-ExistingBundle -BundlePath $destinationBundle
Copy-Item -LiteralPath $sourceBundle -Destination $destinationRoot -Recurse -Force

Write-Host "CadPoints bylo nainstalováno."
Write-Host "Zdroj: $sourceBundle"
Write-Host "Cil:   $destinationBundle"
Write-Host "Restartuj AutoCAD LT 2026.1.1 (W.164.0.0), aby se balicek nacetl."
