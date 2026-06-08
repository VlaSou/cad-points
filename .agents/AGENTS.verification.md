# AGENTS.verification.md

This file is for a local verification agent that can run AutoCAD LT on Windows.

Related runbooks:

- `AGENTS.base.md` for baseline AI coding-agent rules
- `AGENTS.development.md` for implementation and packaging work
- `AGENTS.test.md` for static checks, release validation, and smoke-test steps

## Goal

Verify that CadPoints can be:

1. cloned from GitHub,
2. installed locally without admin rights,
3. loaded by AutoCAD LT,
4. exercised through the main commands,
5. validated with a real AutoCAD LT smoke test.

## Prerequisites

- Windows 10 or newer
- Git
- Python 3.11+ installed and available as `py`
- AutoCAD LT 2024 or newer
- Permission to launch AutoCAD LT interactively

## Repository

Canonical repository:

```text
git@github.com:VlaSou/cad-points.git
```

Canonical source bundle:

```text
src/CadPoints.bundle
```

Generated package payload / staging output:

```text
dist/CadPoints.bundle
```

## Verification Workflow

### 1. Clone the repository

Clone the repo from GitHub into a local working folder and change into it.

### 2. Inspect the package

Confirm that these files exist:

```text
package.json
scripts/release.py
scripts/version.py
scripts/install_windows.bat
tests/run_static_tests.py
src/CadPoints.bundle/PackageContents.xml
src/CadPoints.bundle/Contents/LISP/cadpoints.lsp
```

### 3. Run static checks

From the repository root, run:

```text
py -3 tests/run_static_tests.py
```

Expected result:

```text
STATIC TESTS OK
```

### 4. Prepare package payload and build the autoinstaller

From the repository root, run:

```text
py -3 scripts/release.py --package-only
py -3 scripts/release.py
```

Expected result:

```text
releases/CadPoints_LT_Plugin_vX_Y_Z.zip
```

Treat `dist/` as the intermediate package payload for npm/GitHub Packages and `releases/` as the tracked downloadable autoinstaller artifact output.

The ZIP must contain:

```text
CadPoints.bundle/PackageContents.xml
CadPoints.bundle/Contents/...
install_windows.bat
```

### 5. Install without admin rights

Use the Windows installer script from the repository or from the release ZIP:

```text
scripts\install_windows.bat
```

The bundle must be copied to:

```text
%APPDATA%\Autodesk\ApplicationPlugins\CadPoints.bundle
```

### 6. Configure AutoCAD LT trust paths

In AutoCAD LT, check and if necessary set:

```text
APPAUTOLOAD
APPAUTOLOADER
SECURELOAD
TRUSTEDPATHS
```

For user-profile installation, the trusted path should include:

```text
%APPDATA%\Autodesk\ApplicationPlugins
```

Restart AutoCAD LT after changing trust or autoload settings.

### 7. Load the bundle

Verify that AutoCAD LT sees the bundle in `APPAUTOLOADER`.

If autoload does not work, load the LISP file manually:

```text
APPLOAD
```

Then open:

```text
CadPoints.bundle\Contents\LISP\cadpoints.lsp
```

### 8. Run the commands

After loading, verify that these commands exist:

```text
CPSETTINGS
CPEXPORT
CPHELP
```

Run them in this order:

```text
CPHELP
CPSETTINGS
CPEXPORT
```

### 9. Smoke test in AutoCAD LT

Open the example drawing:

```text
CadPoints.bundle\Contents\Test\example_test.dxf
```

Then load the smoke test LISP:

```text
CadPoints.bundle\Contents\Test\cadpoints_smoke_test.lsp
```

Run the smoke-test command from the LISP helper.

Expected runtime results:

- CSV output is created
- point entities are created on `CADPOINTS_POINTS`
- point labels are created on `CADPOINTS_POINT_LABELS`
- the table is inserted to the right of the maximum X coordinate
- point naming follows the configured naming rule
- curve sampling uses the configured interval
- unsupported geometry is reported gracefully instead of crashing

### 10. Record the result

Record:

- whether the bundle autoloaded
- whether manual `APPLOAD` worked
- whether `CPEXPORT` produced the expected outputs
- whether any AutoCAD LT warnings or command-line errors appeared
- whether the test was done on a clean machine or on a developer workstation

## Success Criteria

Treat the package as verified only when:

1. static tests pass,
2. the release ZIP is valid,
3. the installer places the bundle in the correct user path,
4. AutoCAD LT recognizes the bundle,
5. the main commands run successfully,
6. the smoke test passes on a real AutoCAD LT session.

## Notes

- Do not claim runtime verification unless AutoCAD LT was actually used.
- Prefer the user-profile install path unless a machine-wide install is explicitly required.
- If the bundle does not autoload, inspect `APPAUTOLOADER`, `SECURELOAD`, and `TRUSTEDPATHS` before changing the package.
