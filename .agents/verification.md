# verification.md

Scope: end-to-end verification workflow for a local agent that can run AutoCAD LT on Windows.

This is the procedure for proving a CadPoints package works. Use `requirements.md` for workstation capabilities, installed AutoCAD details, PATH/COM notes, license-dialog notes, and local automation constraints.

Related runbooks:

- `base.md` for baseline AI coding-agent rules
- `development.md` for implementation and packaging work
- `test.md` for static checks, release validation, and smoke-test steps
- `requirements.md` for local runtime-test environment requirements

## Goal

Verify that CadPoints can be:

1. cloned from GitHub,
2. installed locally without admin rights,
3. loaded by AutoCAD LT,
4. exercised through the main commands,
5. validated with a real AutoCAD LT smoke test.

## Environment Gate

Before running this workflow, confirm the workstation matches `requirements.md`.

Current local assumptions:

- Python is installed; run repository scripts with `py -3`.
- AutoCAD LT is already installed locally; do not install, repair, upgrade, or reinstall AutoCAD unless explicitly requested.
- Do not close existing user-owned AutoCAD LT windows. For automated verification, launch a dedicated test instance and track only that process.
- If a license/trial dialog appears, leave it open by default because commands may still run underneath it. Only handle dialogs that are confirmed to block the dedicated test instance.
- Do not use `SendKeys`, focus stealing, synthetic keyboard input, or active-window typing for verification unless the user explicitly approves the exact action.

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

Do not edit an already committed release ZIP in place. Bump the SemVer version first and create a new ZIP.

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

### 9. Deterministic runtime smoke test in AutoCAD LT

Preferred automated smoke test:

```text
CadPoints.bundle\Contents\Test\cadpoints_runtime_smoke_test.lsp
```

Command:

```text
CPFULLSMOKE
```

This creates deterministic input geometry in the current drawing, runs `CPEXPORT`, and compares the generated CSV with:

```text
CadPoints.bundle\Contents\Test\expected_output.csv
```

Expected local result files:

```text
runtime/cadpoints-runtime-result.txt
runtime/cadpoints-runtime-export.csv
```

### 10. Manual example-drawing smoke test

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

### 11. Record the result

Record:

- whether the bundle autoloaded
- whether manual `APPLOAD` worked
- whether `CPEXPORT` produced the expected outputs
- whether `CPFULLSMOKE` matched `expected_output.csv`
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
