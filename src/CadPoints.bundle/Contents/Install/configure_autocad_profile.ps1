param(
    [Parameter(Mandatory = $true)]
    [string]$BundlePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$lispPath = Join-Path $BundlePath 'Contents\LISP'
$cadpointsLisp = Join-Path $lispPath 'cadpoints.lsp'

if (-not (Test-Path -LiteralPath $cadpointsLisp)) {
    throw "CadPoints LISP not found: $cadpointsLisp"
}

function Add-SemicolonPath {
    param(
        [string]$CurrentValue,
        [string]$PathToAdd
    )

    $parts = @($CurrentValue -split ';' | Where-Object { $_ })
    foreach ($part in $parts) {
        if ($part.TrimEnd('\') -ieq $PathToAdd.TrimEnd('\')) {
            return $CurrentValue
        }
    }

    $newValue = ($parts + $PathToAdd) -join ';'
    if (-not $newValue.EndsWith(';')) {
        $newValue += ';'
    }
    return $newValue
}

$root = 'HKCU:\Software\Autodesk\AutoCAD LT'
if (-not (Test-Path -LiteralPath $root)) {
    Write-Host 'AutoCAD LT user profile registry was not found. Bundle files were installed, but profile autoload was not configured.'
    exit 0
}

$profiles = Get-ChildItem -LiteralPath $root -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -like '*\Profiles\*\General' }

$configured = 0
foreach ($profile in $profiles) {
    $props = Get-ItemProperty -LiteralPath $profile.PSPath
    if (-not (Get-Member -InputObject $props -Name 'Support' -MemberType NoteProperty)) {
        continue
    }

    $oldSupport = [string]$props.Support
    $newSupport = Add-SemicolonPath -CurrentValue $oldSupport -PathToAdd $lispPath
    if ($newSupport -ne $oldSupport) {
        New-ItemProperty -LiteralPath $profile.PSPath -Name 'Support' -Value $newSupport -PropertyType ExpandString -Force | Out-Null
        Write-Host "Added CadPoints LISP support path to $($profile.Name)"
    } else {
        Write-Host "CadPoints LISP support path already present in $($profile.Name)"
    }

    $configured += 1
}

if ($configured -eq 0) {
    Write-Host 'No AutoCAD LT profile Support values were found. Bundle files were installed, but profile autoload was not configured.'
}
