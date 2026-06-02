# AGENTS.development.md

This file is for agents working on implementation, packaging, documentation, and repository maintenance.

Related runbooks:

- `AGENTS.test.md` for static validation and runtime smoke-test workflow
- `AGENTS.verification.md` for the full local clone/install/AutoCAD verification flow

## Project Summary

CadPoints is an AutoCAD LT compatible `.bundle` plugin for extracting, naming, labelling, tabulating, and exporting coordinate points from selected CAD geometry layers.

## Canonical Paths

- Repository root: `c:\CODE\cad-points`
- Canonical editable bundle source: `src/CadPoints.bundle`
- Generated installable bundle: `dist/CadPoints.bundle`
- Release ZIP output: `releases/CadPoints_LT_Plugin_vX_Y_Z.zip`
- Agent runbooks: `.agents/`

## Target Environment

- Primary target: AutoCAD LT 2024+
- Runtime focus in docs and smoke tests: AutoCAD LT 2026.1.1
- Windows-only installer flow for now

## Non-Negotiable Rules

- Keep the core workflow in AutoLISP and `.bundle` packaging.
- Do not migrate the workflow to ObjectARX, .NET, VBA, or an external runtime unless explicitly requested.
- Treat all drawings as millimetre-based unless the user explicitly states otherwise.
- Keep generated outputs separate from source.
- Update `TODO.md` after each completed task.
- Prefer `pnpm` if package-manager-driven commands are needed.

## Repository Layout

```text
src/CadPoints.bundle/   editable bundle source tracked by Git
dist/CadPoints.bundle/  generated installable bundle
scripts/                build and installer scripts
tests/                  static and installer tests
releases/               generated ZIP artifacts
.agents/                agent runbooks and verification instructions
docs/                   developer and settings documentation
```

## Commands Exposed by the Plugin

- `CPEXPORT`
- `CPSETTINGS`
- `CPHELP`

## Core Behavior

### CPEXPORT

Main export command. It must:

1. collect supported objects from configured source layers,
2. extract or sample points,
3. generate point names,
4. optionally create point entities in a dedicated point layer,
5. optionally create point labels in a dedicated label layer,
6. export the point table to CSV,
7. optionally draw a table into the DWG,
8. optionally generate contour-like curves from Z values.

### CPSETTINGS

Central configuration command. It controls:

- source layers
- CSV/table columns
- drawing scale
- table scale
- curve sampling enabled/disabled
- curve sampling interval in mm
- point naming pattern
- point output layer
- point label output layer
- point label enabled/disabled
- point label paper height
- table insertion enabled/disabled
- table paper text height
- table paper offset from max X
- table layer
- contour generation enabled/disabled
- contour interval in mm
- contour layer
- contour output as SPLINE enabled/disabled

### CPHELP

Short command summary and workflow help for command-line use in AutoCAD LT.

## Geometry Support

Supported entity types:

- `LINE`
- `LWPOLYLINE`
- `POLYLINE`
- `ARC`
- `CIRCLE`
- `ELLIPSE`
- `SPLINE`

For curved geometry, the default sample interval is `1000 mm`.

## Units and Scale

- Default drawing units are millimetres.
- `1 drawing unit = 1 mm`
- Drawing scale is separate from table scale.
- Point labels use drawing scale.
- Tables use table scale.
- Do not conflate the two.

Default paper-based values:

- curve sample interval: `1000 mm`
- contour interval: `1000 mm`
- point label height: `2.5 mm` on paper
- table text height: `2.5 mm` on paper
- table offset: `50 mm` on paper

## Point Naming

Two naming modes exist:

- layer suffix naming when the pattern is empty
- pattern naming when a pattern is configured

If the pattern is empty, use the suffix after the last underscore in the source layer.

If a pattern contains `#`, the hash run defines the numeric placeholder and the number is zero-padded to that width.

## Output Layers

Default output layers:

- `CADPOINTS_POINTS`
- `CADPOINTS_POINT_LABELS`
- `CADPOINTS_TABLE`
- `CADPOINTS_CONTOURS`

Generated point entities and labels must not go on the source layer.

## CSV and Table Columns

Default column configuration:

```text
POINT_NAME:Bod;LAYER:Hladina;ENTITY_TYPE:Objekt;VERTEX_NO:Vrchol;Y_SJTSK:Y S-JTSK;X_SJTSK:X S-JTSK;Z:Z
```

Supported field IDs:

- `POINT_NAME`
- `POINT_NO`
- `LAYER`
- `ENTITY_TYPE`
- `HANDLE`
- `VERTEX_NO`
- `Y_SJTSK`
- `X_SJTSK`
- `Z`

## S-JTSK Convention

The plugin does not transform coordinates.

Default mapping:

- `Y_SJTSK = AutoCAD X`
- `X_SJTSK = AutoCAD Y`
- `Z = AutoCAD Z`

Do not change this convention without confirming the geodetic output format with the user.

## Table Placement

The table is placed to the right of the maximum X coordinate of the extracted/generated points.

Formula:

```text
table insertion X = max point X + table offset in model units
```

## Contours

Contour generation is approximate:

1. collect segments from supported geometry,
2. interpolate points where segment Z crosses contour levels,
3. group by contour level,
4. create `SPLINE` if possible,
5. fallback to `LWPOLYLINE` if needed.

This is not equivalent to Civil 3D terrain contours.

## Documentation Files

- Root user README: `README.md`
- Czech user README: `README.cs-CZ.md`
- Bundle README: `src/CadPoints.bundle/README.md`
- Developer docs: `docs/development.md`
- Settings docs: `docs/settings.md`
- Help HTML: `src/CadPoints.bundle/Contents/Resources/help.html`

## Release Workflow

Before each release:

1. bump the version in all versioned files,
2. run static tests,
3. build the release ZIP,
4. verify ZIP contents,
5. ensure `dist/CadPoints.bundle` is not open in another app if a clean refresh is required.

Current pnpm-first entrypoints:

```text
pnpm check
pnpm build:zip
pnpm release
pnpm release:check
```

`pnpm release` delegates to `scripts/release.mjs`, which wraps the Python release build.

## Installer Notes

- Primary user-level installer: `scripts/install_windows.bat`
- Installation path: `%APPDATA%\Autodesk\ApplicationPlugins\CadPoints.bundle`
- No admin rights should be required for the default install path.

## Maintenance Rules

- Update README files whenever adding or changing a setting.
- Add or update tests whenever changing extraction, naming, table, scale, or contour logic.
- Keep the implementation AutoCAD LT compatible first.
