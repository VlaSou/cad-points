# CadPoints Development Notes

This document is for maintainers and integrators.

## Repository Layout

```text
src/CadPoints.bundle/   editable bundle source
dist/CadPoints.bundle/  generated installable bundle
scripts/                release and helper scripts
tests/                  static and installer tests
releases/               generated ZIP releases
```

## Build And Release

Run the static checks and create the release ZIP from the repository root:

```text
python tests/run_static_tests.py
python scripts/build_release.py
```

The release ZIP is expected to contain:

```text
CadPoints.bundle/PackageContents.xml
CadPoints.bundle/Contents/...
install_windows.bat
```

## Testing Workflow

Static validation is not enough for a final release. The bundle must also be tested in AutoCAD LT 2026.1.1 on a real Windows PC.

Suggested runtime sequence:

```text
APPLOAD CadPoints.bundle\Contents\LISP\cadpoints.lsp
APPLOAD CadPoints.bundle\Contents\Test\cadpoints_smoke_test.lsp
CPSETTINGS
CPEXPORT
```

Expected runtime results:

- CSV file is created
- `POINT` entities are created on `CADPOINTS_POINTS`
- point labels are created on `CADPOINTS_POINT_LABELS`
- the table is inserted to the right of the maximum X coordinate
- expected point name prefixes appear in the output

## Quick Diagnostics

Useful commands when the bundle does not load:

```text
APPAUTOLOAD
APPAUTOLOADER
APPLOAD
TRUSTEDPATHS
```

- `APPAUTOLOAD` should normally allow plug-ins to load.
- `APPAUTOLOADER` can list or reload plug-ins in the application plug-in folder.
- `APPLOAD` can manually load `CadPoints.bundle\Contents\LISP\cadpoints.lsp` for a one-session test.
- `TRUSTEDPATHS` matters if secure mode blocks the bundle or the LISP file.

## AutoCAD LT Limitations

- The package must stay compatible with AutoCAD LT 2024+.
- Do not migrate the workflow to ObjectARX, .NET, VBA, or an external runtime unless explicitly requested.
- Contour output is approximate and not equivalent to a Civil 3D terrain surface.
- Some curve operations may be unavailable in AutoCAD LT; the code should fail gracefully and report the entity type or handle when possible.
