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

If you prefer npm-style entry points, the repository also exposes:

```text
npm run test
npm run build
npm run release
```

This repository is pnpm-first. Use `pnpm` for package-manager-driven commands:

```text
pnpm check
pnpm build:zip
pnpm release
pnpm release:check
```

The release ZIP is expected to contain:

```text
CadPoints.bundle/PackageContents.xml
CadPoints.bundle/Contents/...
install_windows.bat
```

Before each release:

1. Bump the version in the project version source and sync the version string in the README files, `help.html`, and `PackageContents.xml`.
2. Make sure no editor, file browser, AutoCAD session, or preview pane is holding files inside `dist/CadPoints.bundle`.
3. Run `python tests/run_static_tests.py`.
4. Run `python scripts/build_release.py`.
5. Verify the ZIP name and contents before publishing.

If `dist/CadPoints.bundle` is locked by an editor or preview pane, the build script falls back to a temporary staging copy so the ZIP can still be created. For a clean `dist` refresh, close anything that is holding files open and rerun the build.

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
