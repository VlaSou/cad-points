# AGENTS.test.md

This file is for agents that only need to validate the project, build release artifacts, and run AutoCAD LT smoke tests.

Related runbooks:

- `AGENTS.development.md` for implementation and packaging guidance
- `AGENTS.verification.md` for the full local clone/install/AutoCAD verification flow

## Scope

Use this runbook when the task is to:

- verify the repository statically,
- build the release ZIP,
- install the bundle locally,
- run AutoCAD LT runtime smoke tests,
- record whether the package is actually usable.

## What to Check First

Confirm these files exist:

```text
package.json
scripts/build_release.py
scripts/release.py
scripts/version.py
scripts/install_windows.bat
tests/run_static_tests.py
tests/test_install_windows.py
src/CadPoints.bundle/PackageContents.xml
src/CadPoints.bundle/Contents/LISP/cadpoints.lsp
src/CadPoints.bundle/Contents/Test/example_test.dxf
src/CadPoints.bundle/Contents/Test/cadpoints_smoke_test.lsp
```

## Static Validation

From the repository root:

```text
py -3 tests/run_static_tests.py
```

Expected result:

```text
STATIC TESTS OK
```

The static checks should confirm:

- required files exist
- `cadpoints.lsp` parentheses are balanced
- required command names are present
- required settings names are present
- README files mention installation and troubleshooting
- `package.json` scripts exist and use the pnpm-first workflow

## Release Validation

Build the ZIP:

```text
py -3 scripts/release.py
```

Or use the pnpm entrypoint:

```text
pnpm release
```

Expected ZIP:

```text
releases/CadPoints_LT_Plugin_vX_Y_Z.zip
```

The archive must contain:

```text
CadPoints.bundle/PackageContents.xml
CadPoints.bundle/Contents/...
install_windows.bat
```

The archive must not wrap the bundle in an extra parent folder.

Treat `dist/` as generated package payload / staging output for npm/GitHub Packages and `releases/` as the tracked user-facing autoinstaller artifact output.

## Local Install Validation

Use the Windows installer script:

```text
scripts\install_windows.bat
```

Confirm the bundle ends up in:

```text
%APPDATA%\Autodesk\ApplicationPlugins\CadPoints.bundle
```

## AutoCAD LT Trust Checks

In AutoCAD LT, inspect:

```text
APPAUTOLOAD
APPAUTOLOADER
SECURELOAD
TRUSTEDPATHS
```

For user-profile installs, `TRUSTEDPATHS` should include:

```text
%APPDATA%\Autodesk\ApplicationPlugins
```

If autoload fails, restart AutoCAD LT after changing trust settings.

## Manual Load Check

If the bundle still does not autoload, load the LISP file manually:

```text
APPLOAD
```

Then open:

```text
CadPoints.bundle\Contents\LISP\cadpoints.lsp
```

After loading, verify:

```text
CPSETTINGS
CPEXPORT
CPHELP
```

## Smoke Test in AutoCAD LT

Open the example drawing:

```text
CadPoints.bundle\Contents\Test\example_test.dxf
```

Load the smoke test helper:

```text
CadPoints.bundle\Contents\Test\cadpoints_smoke_test.lsp
```

Run the smoke-test command exposed by that helper and verify:

- CSV output is created
- `POINT` entities appear on `CADPOINTS_POINTS`
- point labels appear on `CADPOINTS_POINT_LABELS`
- the table is inserted to the right of maximum X
- expected point naming prefixes appear
- curve sampling respects the configured interval
- unsupported geometry is reported without crashing AutoCAD LT

## Runtime Result Recording

Record the following:

- whether the bundle autoloaded
- whether manual `APPLOAD` worked
- whether the smoke test created CSV output
- whether the point layer and label layer were populated correctly
- whether any command-line errors or warning dialogs appeared
- which AutoCAD LT version was used
- whether the test was run on a clean machine or a dev workstation

## Pass Criteria

Treat the package as runnable only if:

1. static tests pass,
2. release ZIP builds successfully,
3. the installer copies the bundle to the correct user path,
4. AutoCAD LT can see or load the bundle,
5. `CPSETTINGS`, `CPEXPORT`, and `CPHELP` are available,
6. the smoke test passes in a real AutoCAD LT session.

Do not claim runtime verification unless AutoCAD LT was actually used.
