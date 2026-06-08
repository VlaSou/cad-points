# CadPoints Local Runtime Test Requirements

This file lists optional workstation setup that improves automated CadPoints testing in AutoCAD LT.

## Required For True Runtime Verification

- Windows 10 or newer.
- AutoCAD LT 2024 or newer with AutoLISP support.
- A working AutoCAD LT license or trial.
- Python 3.11+ available through `py -3`.
- Permission to launch and close AutoCAD LT from scripts.
- Permission to install/reinstall only `CadPoints.bundle` into:

```text
%APPDATA%\Autodesk\ApplicationPlugins\CadPoints.bundle
```

Do not install, repair, upgrade, or reinstall AutoCAD itself unless explicitly requested.

## Current Local AutoCAD Setup

Current detected executable:

```text
D:\Autodesk\AutoCAD LT 2026\acadlt.exe
```

Current useful registry / product hints:

```text
AutoCAD LT 2026
R32
ACADLT-9101
ACADLT-9101:405
```

The `:405` profile/locale suffix indicates Czech-localized AutoCAD LT profile data.

## Helpful PATH / Alias Setup

It is helpful if `acad` or `acadlt` resolves to the installed AutoCAD LT executable in normal user shells.

Example target:

```text
D:\Autodesk\AutoCAD LT 2026\acadlt.exe
```

If aliases are shell-profile-only, they may not be visible to non-profile automation shells. A system/user PATH entry to the AutoCAD LT install folder is more reliable than a PowerShell-only alias.

## PowerShell / COM Automation

PowerShell 7 in this sandbox does not expose `Marshal.GetActiveObject` reliably.

For AutoCAD COM automation, prefer Windows PowerShell 5.1:

```text
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile
```

Known AutoCAD LT 2026 ProgIDs found locally:

```text
AutoCAD.Application.25.1
AutoCAD.Application.25
```

The generic ProgID may fail for AutoCAD LT:

```text
AutoCAD.Application
```

COM automation is useful but not guaranteed. If the running AutoCAD LT instance is not registered in the Running Object Table, `GetActiveObject` can return `MK_E_UNAVAILABLE` even while `acadlt.exe` is running.

## License / First Run Dialogs

Automated `/b` scripts can be blocked by license, first-run, profile migration, trust, or unregistered-version dialogs.

Before automated runtime verification:

- Open AutoCAD LT manually once.
- Close or accept any license/trial/startup dialogs.
- Let profile creation finish.
- Close extra AutoCAD LT windows before the test.

Agents may close stale AutoCAD LT test instances before retrying runtime tests.

## AutoCAD Trust And Autoload Settings

After installing CadPoints, verify these in AutoCAD LT:

```text
APPAUTOLOAD
APPAUTOLOADER
SECURELOAD
TRUSTEDPATHS
APPLOAD
```

Recommended user plug-in path:

```text
%APPDATA%\Autodesk\ApplicationPlugins
```

If secure loading blocks LISP or bundle loading, add the user `ApplicationPlugins` folder to trusted paths through AutoCAD LT.

## Runtime Test Flow

The automated runtime smoke test is:

```text
CadPoints.bundle\Contents\Test\cadpoints_runtime_smoke_test.lsp
```

The command is:

```text
CPFULLSMOKE
```

It creates deterministic input geometry in the current drawing and compares the generated CSV against:

```text
CadPoints.bundle\Contents\Test\expected_output.csv
```

Expected generated runtime files during local testing:

```text
runtime/cadpoints-runtime-result.txt
runtime/cadpoints-runtime-export.csv
```

## What Helps Most

The most useful workstation improvements are:

1. Make sure AutoCAD LT can launch without license or first-run dialogs.
2. Add `D:\Autodesk\AutoCAD LT 2026\` to user PATH so `acadlt.exe` resolves in non-profile shells.
3. Confirm `%APPDATA%\Autodesk\ApplicationPlugins` is trusted or not blocked by `SECURELOAD`.
4. Keep only one AutoCAD LT instance open during automated tests.
5. Allow scripts to close stale AutoCAD LT test instances.
6. Keep Windows PowerShell 5.1 available for COM attempts.

## Not Required

The following are not required for CadPoints runtime verification:

- Full AutoCAD instead of AutoCAD LT.
- ObjectARX SDK.
- .NET plugin tooling.
- VBA.
- Admin install into AutoCAD program folders.
- Fake DWG generation outside AutoCAD.

CadPoints should remain a lightweight AutoCAD LT `.bundle` plugin.
