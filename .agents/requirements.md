# requirements.md

Scope: local workstation capabilities and setup assumptions that make automated CadPoints runtime testing possible.

This is not the verification procedure. Use `verification.md` for the actual end-to-end test workflow and result criteria.

## Baseline Workstation

- Windows 10 or newer.
- AutoCAD LT 2024 or newer with AutoLISP support.
- A working AutoCAD LT license or trial.
- Python is installed on this workstation; use `py -3` for repository scripts.
- Permission to launch AutoCAD LT from scripts for CadPoints verification.
- Permission to install or reinstall only `CadPoints.bundle` into:

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

Agents may make targeted changes under `D:\Autodesk\` for CadPoints verification when needed, but must not install, repair, upgrade, or reinstall AutoCAD without an explicit user request.

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

Automated `/b` scripts can be blocked by first-run, profile migration, trust, or unregistered-version dialogs. The local license/trial dialog may appear visually while commands still run underneath it, so do not close it automatically.

Before automated runtime verification:

- Open AutoCAD LT manually once.
- Do not close, accept, or type into startup dialogs from automation unless the user explicitly approves that exact action.
- Let profile creation finish.
- If user-owned AutoCAD LT windows are open, leave them open unless the user explicitly asks to close them.

Agents must not automatically close the license/trial dialog. If a dialog is suspected to block automation, first confirm that the command/script is actually blocked and record the finding. Agents must not close arbitrary Windows or existing user-owned AutoCAD LT instances. If an automated test needs a clean process, launch a dedicated test instance and track only that process.

## GUI Automation Ban

Do not use desktop-level GUI automation for AutoCAD verification by default.

Forbidden unless explicitly approved for the exact current action:

```text
SendKeys
synthetic keyboard input
SetForegroundWindow
ShowWindow
clicking or closing dialogs
typing commands into the active Windows window
```

Use `/b` script files, AutoLISP test helpers, result files, or targeted COM calls instead. COM calls must target a known AutoCAD object; they must not rely on the active desktop window or keyboard focus.

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

## Runtime Smoke Assets

The automated runtime smoke test assets are:

```text
CadPoints.bundle\Contents\Test\cadpoints_runtime_smoke_test.lsp
CadPoints.bundle\Contents\Test\expected_output.csv
```

The command is:

```text
CPFULLSMOKE
```

Expected generated runtime files during local testing:

```text
.test/cadpoints-runtime-result.txt
.test/cadpoints-runtime-export.csv
```

## What Helps Most

The most useful workstation improvements are:

1. Make sure AutoCAD LT can launch without license or first-run dialogs.
2. Add `D:\Autodesk\AutoCAD LT 2026\` to user PATH so `acadlt.exe` resolves in non-profile shells.
3. Confirm `%APPDATA%\Autodesk\ApplicationPlugins` is trusted or not blocked by `SECURELOAD`.
4. Keep the automated test in a dedicated AutoCAD LT instance when possible.
5. Do not close user-owned AutoCAD LT windows; if any dialog appears to block the dedicated test instance, stop and ask before taking any GUI action.
6. Keep Windows PowerShell 5.1 available for COM attempts.

## Not Required

The following are not required for CadPoints runtime verification:

- Installing Python on this workstation; it is already available.
- Full AutoCAD instead of AutoCAD LT.
- ObjectARX SDK.
- .NET plugin tooling.
- VBA.
- Admin install into AutoCAD program folders.
- Fake DWG generation outside AutoCAD.

CadPoints should remain a lightweight AutoCAD LT `.bundle` plugin.
