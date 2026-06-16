#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [string]$SourceBundle,
    [string]$OutputDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-FullPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return [System.IO.Path]::GetFullPath($Path)
}

function Read-PackageVersion {
    param([Parameter(Mandatory = $true)][string]$BundlePath)

    $packagePath = Join-Path $BundlePath 'PackageContents.xml'
    if (-not (Test-Path -LiteralPath $packagePath)) {
        throw "Missing PackageContents.xml in $BundlePath"
    }

    [xml]$packageXml = Get-Content -LiteralPath $packagePath
    $version = $packageXml.ApplicationPackage.AppVersion
    if (-not $version) {
        throw "PackageContents.xml is missing AppVersion"
    }
    return $version
}

function Convert-VersionSlug {
    param([Parameter(Mandatory = $true)][string]$Version)
    return $Version.Replace('.', '_')
}

function New-CleanDirectory {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
}

function Resolve-CSharpCompiler {
    $candidates = @(
        (Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'),
        (Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319\csc.exe')
    )

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }

    throw 'Could not find .NET Framework csc.exe. Install .NET Framework developer tools or use the ZIP installer.'
}

$scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $SourceBundle) {
    $SourceBundle = Join-Path $scriptRoot '..\dist\CadPoints.bundle'
}
if (-not $OutputDir) {
    $OutputDir = Join-Path $scriptRoot '..\releases'
}

$sourceBundlePath = Resolve-FullPath -Path $SourceBundle
$outputDirPath = Resolve-FullPath -Path $OutputDir
$installerBat = Resolve-FullPath -Path (Join-Path $scriptRoot 'install_windows.bat')
$csc = Resolve-CSharpCompiler

if (-not (Test-Path -LiteralPath (Join-Path $sourceBundlePath 'PackageContents.xml'))) {
    throw "Source bundle is invalid: $sourceBundlePath"
}
if (-not (Test-Path -LiteralPath $installerBat)) {
    throw "Missing installer batch file: $installerBat"
}

$version = Read-PackageVersion -BundlePath $sourceBundlePath
$versionSlug = Convert-VersionSlug -Version $version
$exePath = Join-Path $outputDirPath "CadPoints_LT_Plugin_v$versionSlug.exe"

$workRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("cadpoints-exe-build-" + [System.Guid]::NewGuid().ToString('N'))
$payloadRoot = Join-Path $workRoot 'payload'
New-CleanDirectory -Path $payloadRoot
New-Item -ItemType Directory -Path $outputDirPath -Force | Out-Null

try {
    Copy-Item -LiteralPath $sourceBundlePath -Destination (Join-Path $payloadRoot 'CadPoints.bundle') -Recurse -Force
    Copy-Item -LiteralPath $installerBat -Destination (Join-Path $payloadRoot 'install_windows.bat') -Force

    $payloadZip = Join-Path $workRoot 'CadPoints_payload.zip'
    Compress-Archive -Path (Join-Path $payloadRoot '*') -DestinationPath $payloadZip -Force

    $sourcePath = Join-Path $workRoot 'CadPointsInstaller.cs'
    @'
using System;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Reflection;

internal static class Program
{
    private const string ResourceName = "CadPoints_payload.zip";

    private static int Main(string[] args)
    {
        string tempRoot = Path.Combine(Path.GetTempPath(), "CadPointsInstaller_" + Guid.NewGuid().ToString("N"));
        bool quiet = HasArg(args, "/Q") || HasArg(args, "/QUIET") || HasArg(args, "--quiet");

        try
        {
            Directory.CreateDirectory(tempRoot);
            string payloadZip = Path.Combine(tempRoot, ResourceName);
            ExtractResource(payloadZip);

            string payloadDir = Path.Combine(tempRoot, "payload");
            Directory.CreateDirectory(payloadDir);
            ZipFile.ExtractToDirectory(payloadZip, payloadDir);

            string installer = Path.Combine(payloadDir, "install_windows.bat");
            string bundle = Path.Combine(payloadDir, "CadPoints.bundle");
            if (!File.Exists(installer))
            {
                throw new FileNotFoundException("Missing install_windows.bat in installer payload.", installer);
            }
            if (!File.Exists(Path.Combine(bundle, "PackageContents.xml")))
            {
                throw new FileNotFoundException("Missing CadPoints.bundle in installer payload.", bundle);
            }

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "cmd.exe";
            startInfo.Arguments = "/c \"\"" + installer + "\" \"" + bundle + "\"\"";
            startInfo.UseShellExecute = false;
            startInfo.CreateNoWindow = quiet;
            startInfo.WorkingDirectory = payloadDir;

            using (Process process = Process.Start(startInfo))
            {
                process.WaitForExit();
                if (process.ExitCode != 0)
                {
                    throw new InvalidOperationException("install_windows.bat failed with exit code " + process.ExitCode);
                }
            }

            if (!quiet)
            {
                Console.WriteLine("CadPoints installer finished.");
            }
            return 0;
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine("CadPoints installer failed:");
            Console.Error.WriteLine(ex.Message);
            return 1;
        }
        finally
        {
            try
            {
                if (Directory.Exists(tempRoot))
                {
                    Directory.Delete(tempRoot, true);
                }
            }
            catch
            {
            }
        }
    }

    private static bool HasArg(string[] args, string value)
    {
        foreach (string arg in args)
        {
            if (string.Equals(arg, value, StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }
        }
        return false;
    }

    private static void ExtractResource(string outputPath)
    {
        Assembly assembly = Assembly.GetExecutingAssembly();
        using (Stream input = assembly.GetManifestResourceStream(ResourceName))
        {
            if (input == null)
            {
                throw new InvalidOperationException("Embedded payload resource was not found.");
            }
            using (FileStream output = File.Create(outputPath))
            {
                input.CopyTo(output);
            }
        }
    }
}
'@ | Set-Content -LiteralPath $sourcePath -Encoding ASCII

    $references = @(
        '/r:System.dll',
        '/r:System.Core.dll',
        '/r:System.IO.Compression.dll',
        '/r:System.IO.Compression.FileSystem.dll'
    )
    $arguments = @(
        '/nologo',
        '/target:exe',
        "/out:$exePath",
        "/resource:$payloadZip,CadPoints_payload.zip"
    ) + $references + @($sourcePath)

    & $csc @arguments
    if ($LASTEXITCODE -ne 0) {
        throw "csc.exe failed with exit code $LASTEXITCODE"
    }

    if (-not (Test-Path -LiteralPath $exePath)) {
        throw "Installer EXE was not created: $exePath"
    }

    Write-Host "Created $exePath"
}
finally {
    if (Test-Path -LiteralPath $workRoot) {
        Remove-Item -LiteralPath $workRoot -Recurse -Force
    }
}
