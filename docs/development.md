# CadPoints Development Notes

This document is for maintainers and integrators.

## Repository Layout

```text
src/CadPoints.bundle/   editable bundle source
dist/CadPoints.bundle/  generated package payload / staging output
scripts/                release and helper scripts
tests/                  static and installer tests
releases/               tracked release ZIPs for published versions
.agents/                agent runbooks and local verification requirements
```

## Build And Release

Run the static checks and create the release ZIP from the repository root:

```text
python tests/run_static_tests.py
python scripts/release.py --package-only
python scripts/release.py
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
pnpm package:dist
pnpm build:autoinstaller
pnpm build:installer-exe
pnpm installer-exe:check
pnpm release
pnpm release:check
```

`pnpm package:dist` delegates to `scripts/release.py --package-only` and prepares the npm/GitHub Packages payload in `dist/`.
`pnpm build:autoinstaller` and `pnpm release` delegate to `scripts/release.py` and build the tracked installer ZIP in `releases/`.
`pnpm build:installer-exe` delegates to `scripts/build_installer_exe.ps1` and builds the self-contained Windows installer EXE in `releases/`.

The release ZIP is expected to contain:

```text
CadPoints.bundle/PackageContents.xml
CadPoints.bundle/Contents/...
install_windows.bat
```

Keep `install_windows.bat` in the ZIP root next to `CadPoints.bundle`, not inside the bundle. The `.bundle` directory should remain the clean AutoCAD plug-in payload.

`dist/` is generated output and is not tracked in Git. It is the package payload used for npm/GitHub Packages publishing and for assembling the autoinstaller ZIP.

`releases/` is tracked in Git and contains the generated autoinstaller ZIPs for published versions. If you add a new release, commit the ZIP so the repository history includes the distributable artifact.

Already committed release ZIPs are immutable. Do not rebuild or edit a published ZIP in place. Bump the SemVer version first and create a new `CadPoints_LT_Plugin_vX_Y_Z.zip`.

Longer term, the preferred user-facing distribution should become a self-contained executable installer, with the release ZIP remaining the build artifact used to produce it. Treat MSI as a later enterprise/deployment target, not the immediate default for this lightweight plugin.

The first `.exe` installer uses the local .NET Framework C# compiler so the repository can build a self-extracting installer without adding WiX/Inno/NSIS dependencies. The `.exe` payload contains `CadPoints.bundle` and `install_windows.bat`, then auto-runs the batch installer after extraction. IExpress was rejected for this project because local testing produced a `LoadString() Error. Could not load string resource.` dialog.

Before each release:

1. Bump the version with the SemVer script from `package.json`:
   - `pnpm version:patch`
   - `pnpm version:minor`
   - `pnpm version:major`
2. Confirm the versioned files in the README files, `help.html`, and `PackageContents.xml` were updated together.
3. Make sure no editor, file browser, AutoCAD session, or preview pane is holding files inside `dist/CadPoints.bundle`.
4. Run `python tests/run_static_tests.py`.
5. Run `python scripts/release.py --package-only` if you need the npm/GitHub Packages payload.
6. Run `python scripts/release.py` for the autoinstaller ZIP.
7. Run `pnpm build:installer-exe` for the self-contained Windows installer.
8. Run `pnpm installer-exe:check`.
9. Verify the ZIP/EXE names and contents before publishing.

If `dist/CadPoints.bundle` is locked by an editor or preview pane, the build script falls back to a temporary staging copy so the ZIP can still be created. For a clean `dist` refresh, close anything that is holding files open and rerun the build.

## Testing Workflow

Static validation is not enough for a final release. The bundle must also be tested in AutoCAD LT 2026.1.1 on a real Windows PC.

Local automation requirements and current workstation details are tracked in:

```text
.agents/requirements.md
```

Suggested runtime sequence:

```text
APPLOAD CadPoints.bundle\Contents\LISP\cadpoints.lsp
APPLOAD CadPoints.bundle\Contents\Test\cadpoints_runtime_smoke_test.lsp
APPLOAD CadPoints.bundle\Contents\Test\cadpoints_smoke_test.lsp
CPFULLSMOKE
CPSETTINGS
CPEXPORT
```

Expected runtime results:

- CSV file is created
- `CPFULLSMOKE` compares the generated CSV with `expected_output.csv`
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

For a shareable local report, run:

```text
pnpm diagnostics
```

Or save it to a file:

```text
py -3 scripts/diagnostics.py > cadpoints-diagnostics.txt
```

## AutoCAD LT Limitations

- The package must stay compatible with AutoCAD LT 2024+.
- Do not migrate the workflow to ObjectARX, .NET, VBA, or an external runtime unless explicitly requested.
- Contour output is approximate and not equivalent to a Civil 3D terrain surface.
- Some curve operations may be unavailable in AutoCAD LT; the code should fail gracefully and report the entity type or handle when possible.
