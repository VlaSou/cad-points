# AutoCAD LT Runtime Test Checklist

Use this checklist only on a Windows workstation with AutoCAD LT 2024 or newer.

Do not mark runtime behavior as verified unless the commands were actually run in AutoCAD LT.

## Environment

- Date:
- Workstation:
- AutoCAD LT version:
- Clean machine or developer workstation:
- Installed bundle path:

Expected user-profile install path:

```text
%APPDATA%\Autodesk\ApplicationPlugins\CadPoints.bundle
```

## Load Checks

- [ ] `APPAUTOLOAD` allows application plug-in loading.
- [ ] `APPAUTOLOADER` can see or reload `CadPoints.bundle`.
- [ ] `SECURELOAD` does not block loading, or the path is trusted.
- [ ] `TRUSTEDPATHS` includes `%APPDATA%\Autodesk\ApplicationPlugins` when secure loading requires it.
- [ ] Manual `APPLOAD` can load `CadPoints.bundle\Contents\LISP\cadpoints.lsp`.

## Command Checks

- [ ] `CPHELP` runs and prints command guidance.
- [ ] `CPSETTINGS` runs and shows editable settings.
- [ ] `CPEXPORT` runs on the example drawing without crashing.

## Smoke Test

Open:

```text
CadPoints.bundle\Contents\Test\example_test.dxf
```

Load:

```text
CadPoints.bundle\Contents\Test\cadpoints_smoke_test.lsp
```

Run the smoke-test command documented in the helper, currently:

```text
CPTESTNAMES
```

Record:

- [ ] CSV output is created.
- [ ] `POINT` entities are created on `CADPOINTS_POINTS`.
- [ ] Point labels are created on `CADPOINTS_POINT_LABELS`.
- [ ] Expected point name prefixes are present.
- [ ] Table insertion appears to the right of the maximum point X.
- [ ] Curve sampling uses the configured millimetre interval.
- [ ] Unsupported or failed geometry is reported without crashing AutoCAD LT.

## Result

- Runtime status: not run / passed / failed
- Errors or warnings:
- Follow-up fixes needed:

## 2026-06-08 Workstation Note

Non-AutoCAD checks passed on this workstation, but no `acadlt.exe` or `acad.exe` executable was available, so runtime testing was not performed.
