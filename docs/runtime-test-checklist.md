# AutoCAD LT Runtime Test Checklist

Use this checklist only on a Windows workstation with AutoCAD LT 2024 or newer.

Do not mark runtime behavior as verified unless the commands were actually run in AutoCAD LT.

Workstation capabilities, local AutoCAD path, PATH/COM notes, and trust/autoload requirements are tracked in:

```text
.agents/requirements.md
```

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

## Deterministic Runtime Smoke Test

Preferred automated test:

```text
CadPoints.bundle\Contents\Test\cadpoints_runtime_smoke.scr
CadPoints.bundle\Contents\Test\cadpoints_runtime_smoke_test.lsp
```

Run:

```text
CPFULLSMOKE
```

When using the `.scr` helper, it first appends `CadPoints.bundle\...` to `TRUSTEDPATHS` so AutoCAD LT should not display the unsigned executable-file prompt for `cadpoints_runtime_smoke_test.lsp`.

Expected comparison fixture:

```text
CadPoints.bundle\Contents\Test\expected_output.csv
```

Record:

- [ ] Runtime result file is created.
- [ ] Runtime CSV export is created.
- [ ] CSV output matches `expected_output.csv`.
- [ ] `POINT` entities are created on `CADPOINTS_POINTS`.
- [ ] Point labels are created on `CADPOINTS_POINT_LABELS`.
- [ ] Table insertion appears to the right of the maximum point X.

## Manual Example-Drawing Smoke Test

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

- Runtime status: passed on 2026-06-16
- Errors or warnings: AutoCAD LT showed a license/unregistered-version dialog before `/b` script execution; closing that dialog allowed the script to continue. `fboundp` is unavailable in this AutoCAD LT runtime and was removed from CadPoints runtime code. AutoCAD also showed an unsigned executable-file prompt for the smoke-test LISP until `CadPoints.bundle\...` was added to `TRUSTEDPATHS`; `cadpoints_runtime_smoke.scr` now does this before loading the test helper.
- Follow-up fixes needed: keep closing license/save dialogs before automated attempts; optional next step is manual CUI/ribbon panel verification.

## 2026-06-16 Workstation Result

- AutoCAD LT executable: `D:\Autodesk\AutoCAD LT 2026\acadlt.exe`
- Installed bundle path: `%APPDATA%\Autodesk\ApplicationPlugins\CadPoints.bundle`
- Tested release version: `0.6.3`
- Build/test commands run:
  - `py -3 tests/run_static_tests.py`
  - `py -3 scripts/release.py --package-only`
  - `py -3 scripts/release.py`
  - `scripts\install_windows.bat`
  - AutoCAD LT `/b .test/cadpoints-fullsmoke-diag.scr`
- Runtime result file: `.test/cadpoints-runtime-result.txt`
- Runtime CSV file: `.test/cadpoints-runtime-export.csv`
- Result summary: `CPFULLSMOKE` passed all checks, created 5 records, 5 point entities, 5 labels, and 58 table entities. Generated CSV matched `expected_output.csv`.
- TRUSTEDPATHS verification: `.test/cadpoints-fullsmoke-diag.txt` recorded `C:\Users\vsous\AppData\Roaming\Autodesk\ApplicationPlugins\CadPoints.bundle\...` before loading `cadpoints_runtime_smoke_test.lsp`.

## 2026-06-08 Workstation Note

Non-AutoCAD checks passed on this workstation, but no `acadlt.exe` or `acad.exe` executable was available, so runtime testing was not performed.
