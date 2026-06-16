# AGENTS.md

## Project

Repository:

```text
git@github.com:VlaSou/cad-points.git
```

Project name:

```text
cad-points
```

Purpose:

CadPoints is an AutoCAD LT compatible automation package for extracting, naming, labelling, tabulating, and exporting coordinate points from selected CAD geometry layers. The target environment is AutoCAD LT with AutoLISP support.

The package must remain usable as a lightweight AutoCAD LT `.bundle` plugin.

## Primary target

The primary target is:

```text
AutoCAD LT 2024+
```

The implementation must prefer AutoLISP and `.bundle` packaging.

Do not migrate the core workflow to ObjectARX, .NET, VBA, or external runtime dependencies unless explicitly requested. AutoCAD LT has stricter automation limits than full AutoCAD, so compatibility has priority over architectural elegance.

## Default drawing units

All CAD drawings in this project must be treated as millimetre-based drawings unless the user explicitly states otherwise.

Default model-space assumptions:

```text
1 drawing unit = 1 mm
```

Consequences:

```text
1 m = 1000 drawing units
```

Default values must therefore use millimetres:

```text
Curve sample interval: 1000 mm
Contour interval: 1000 mm
Point label paper height: 2.5 mm converted by drawing scale
Table text paper height: 2.5 mm converted by table scale
Table offset paper distance: 50 mm converted by table scale
```

Never introduce metre-based defaults such as `1` for 1 m unless the setting clearly represents metres and is converted before use.

## Current package state

The latest prepared package version follows SemVer and is stored in `package.json`.

```text
CadPoints_LT_Plugin_vX_Y_Z.zip
```

The package currently contains or should contain:

```text
src/
  CadPoints.bundle/
    PackageContents.xml
    Contents/
      LISP/
        cadpoints.lsp
      Resources/
        cp-export.bmp
        cp-export-16.bmp
        cp-settings.bmp
        cp-settings-16.bmp
        cp-help.bmp
        cp-help-16.bmp
      Menu/
        cadpoints.mnu
      Test/
        example_test.dxf
        create_example_test.scr
        cadpoints_smoke_test.lsp
        README_TEST.md
    README.md
```

The canonical editable bundle source location in this repository is:

```text
src/CadPoints.bundle
```

The editable bundle source is kept in `src/CadPoints.bundle`. The build script copies it to `dist/CadPoints.bundle` as generated output for the npm/GitHub Packages payload and as the staging input for the autoinstaller ZIP. AutoCAD users should install the autoinstaller ZIP contents or the generated bundle payload, not random intermediate files.

Preserve the same logical separation:

```text
src/CadPoints.bundle editable bundle source tracked by Git
dist/CadPoints.bundle generated package payload / staging output
scripts/             repository automation
tests/               repository-level static tests
releases/            tracked autoinstaller ZIP artifacts
.agents/             agent-specific runbooks and verification instructions
docs/                human-facing developer and settings documentation
```

The `.agents/` folder is part of the repository documentation surface for local and future agents. Keep any agent-facing runbooks there, including:

```text
.agents/base.md
.agents/development.md
.agents/test.md
.agents/requirements.md
.agents/verification.md
.agents/autocad.md
```

Add future agent instruction files to the same folder rather than scattering them through the repository root.

Keep `docs/` for human-facing documentation and `.agents/` for agent-facing runbooks.

`.agents/base.md` contains baseline, project-agnostic AI coding-agent rules. This root `AGENTS.md` and the project-specific runbooks extend that baseline with CadPoints-specific compatibility, packaging, testing, and documentation requirements.

## Core commands

The plugin must expose these AutoCAD commands:

```text
CPEXPORT
CPSETTINGS
CPHELP
```

### CPEXPORT

`CPEXPORT` is the main command.

It must:

1. collect supported objects from configured source layers,
2. extract or sample points,
3. generate point names,
4. optionally create point entities in a dedicated point layer,
5. optionally create point labels in a dedicated label layer,
6. export the point table to CSV,
7. optionally draw a table into the DWG,
8. optionally generate contour-like curves from Z values.

### CPSETTINGS

`CPSETTINGS` must remain the central configuration command.

It should configure at least:

```text
Source layers
CSV/table columns
Drawing scale
Table scale
Curve sampling enabled/disabled
Curve sampling interval in mm
Point naming pattern
Point output layer
Point label output layer
Point label enabled/disabled
Point label paper height
Table insertion enabled/disabled
Table paper text height
Table paper offset from max X
Table layer
Contour generation enabled/disabled
Contour interval in mm
Contour layer
Contour output as SPLINE enabled/disabled
```

### CPHELP

`CPHELP` must explain available commands, configuration format, and the expected workflow.

Keep it short enough to be readable in AutoCAD command output.

## Geometry support

The plugin should support at least these entity types:

```text
LINE
LWPOLYLINE
POLYLINE
ARC
CIRCLE
ELLIPSE
SPLINE
```

### Straight geometry

For straight `LINE` entities, use their start and end points.

For straight polylines, use their vertices unless curve sampling is explicitly applied.

### Curved geometry

For curved geometry, sample points along the curve by length.

Default sample interval:

```text
1000 mm
```

The sample interval must be configurable through `CPSETTINGS`.

For unsupported curve operations in AutoCAD LT, provide safe fallbacks instead of crashing. The plugin must fail gracefully and report which entity type or handle could not be sampled.

## Point naming

Point names must support two modes.

### Layer suffix naming

If the point naming pattern is empty, derive the point prefix from the source layer suffix.

Example:

```text
CP_POINTS_A -> A001, A002, A003
CP_POINTS_B -> B001, B002, B003
```

The suffix is the last segment after `_` by default.

Numbering must be independent per suffix.

### Pattern naming

If a pattern is defined, use the pattern instead of layer suffix naming.

Example:

```text
A-SO01-### -> A-SO01-001
P-####     -> P-0001
```

Rules:

1. `#` characters define the numeric placeholder.
2. The number must be zero-padded to the number of `#` characters.
3. If no `#` exists, append a zero-padded 3-digit number to the end.
4. Pattern numbering is global unless the user explicitly requests per-layer pattern counters.

## Output layers

Generated point entities and point labels must be placed in separate layers.

Default layers:

```text
CADPOINTS_POINTS
CADPOINTS_POINT_LABELS
CADPOINTS_TABLE
CADPOINTS_CONTOURS
```

Do not place generated point labels on the original source layer.

Create missing output layers automatically when possible.

## CSV and table columns

CSV and drawn table columns must be configurable.

Column config format:

```text
FIELD_ID:Column title;FIELD_ID:Column title
```

Supported fields:

```text
POINT_NAME
POINT_NO
LAYER
ENTITY_TYPE
HANDLE
VERTEX_NO
Y_SJTSK
X_SJTSK
Z
```

Default config:

```text
POINT_NAME:Bod;LAYER:Hladina;ENTITY_TYPE:Objekt;VERTEX_NO:Vrchol;Y_SJTSK:Y S-JTSK;X_SJTSK:X S-JTSK;Z:Z
```

Users must be able to remove columns by omitting them from the config.

Users must be able to rename columns by changing the text after `:`.

## S-JTSK handling

The plugin does not transform coordinates.

Assume the drawing is already in S-JTSK.

Coordinate output convention:

```text
Y_SJTSK = AutoCAD X coordinate value, labelled as S-JTSK Y when required by table convention
X_SJTSK = AutoCAD Y coordinate value, labelled as S-JTSK X when required by table convention
Z       = AutoCAD Z coordinate value
```

Before changing this convention, confirm the expected geodetic output format with the user.

## Table insertion

The plugin must optionally insert a point table into the drawing.

The insertion point must be placed to the right of the maximum X coordinate of all extracted/generated points.

Formula:

```text
table insertion X = max point X + table offset in model units
```

The table offset must be configured in paper millimetres and converted by table scale:

```text
model offset = paper offset * table scale
```

The table text height must also be configured in paper millimetres and converted by table scale:

```text
model text height = paper text height * table scale
```

Allowed table scale values:

```text
1:25
1:50
1:100
1:500
1:1000
```

Store the numeric scale value as:

```text
25
50
100
500
1000
```

## Drawing scale

Drawing scale is separate from table scale.

Allowed drawing scale values:

```text
1:25
1:50
1:100
1:500
1:1000
```

Use drawing scale for point labels and other drawing annotations.

Use table scale only for table geometry and table text.

Do not conflate drawing scale and table scale.

## Contours

Contour generation is optional.

The current acceptable implementation is approximate:

1. collect segments from supported geometry,
2. interpolate points where segment Z crosses configured contour levels,
3. group points by contour level,
4. create SPLINE if possible,
5. fallback to LWPOLYLINE if SPLINE creation fails or too few points exist.

Default contour interval:

```text
1000 mm
```

This is not a replacement for a real TIN/DMT surface model.

Do not claim that the output is geodetically equivalent to Civil 3D surface contours.

Documentation must clearly state this limitation.

## Ribbon and panel

The project may include helper resources for ribbon/panel setup, but do not rely on a generated binary `.cuix` unless it is created and tested inside AutoCAD.

The README must include manual CUI setup steps.

Required command macros:

```text
^C^C_CPEXPORT
^C^C_CPSETTINGS
^C^C_CPHELP
```

Recommended panel:

```text
CadPoints
```

Recommended buttons:

```text
Export Points
Settings
Help
```

Icons should remain in:

```text
Contents/Resources
```

## Testing requirements

The repository must include test materials.

Preferred test fixture:

```text
Contents/Test/example_test.dxf
```

If a DWG fixture is required, create it inside AutoCAD LT by opening the DXF and saving it as:

```text
example_test.dwg
```

Do not generate fake binary `.dwg` files.

### Smoke test

The package should include:

```text
Contents/Test/cadpoints_smoke_test.lsp
```

The smoke test should verify at least:

```text
required commands load
required settings exist
source layers exist in the example drawing
CPEXPORT can run on example_test.dxf/example_test.dwg
CSV output is created
point labels are created in CADPOINTS_POINT_LABELS
point entities are created in CADPOINTS_POINTS
expected point name prefixes are present
```

### Static tests

If adding repository-level tooling, add a simple static test script that checks:

```text
PackageContents.xml exists
cadpoints.lsp exists
parentheses in cadpoints.lsp are balanced
required command names are present
required setting names are present
README contains install instructions
README contains ribbon/CUI instructions
Test fixture exists
```

Use cross-platform scripts. Prefer Node.js or Python. Avoid PowerShell-only tooling.

## Release process

Release ZIP naming:

```text
CadPoints_LT_Plugin_vX_Y_Z.zip
```

The ZIP must contain the `.bundle` folder at the archive root:

```text
CadPoints.bundle/PackageContents.xml
CadPoints.bundle/Contents/...
```

Do not wrap the bundle in an extra parent folder.

Before release:

1. run static tests,
2. verify ZIP structure,
3. verify README version references,
4. verify PackageContents.xml version,
5. if AutoCAD LT is available, run the smoke test on the example drawing.

Already committed release ZIPs are immutable. Do not edit or rebuild an existing published ZIP in place; bump the SemVer version first and create a new `CadPoints_LT_Plugin_vX_Y_Z.zip`.

## Documentation requirements

Keep README focused on practical use.

README must cover:

```text
installation path
autoload behavior
commands
settings
source layer configuration
column configuration
point naming pattern
layer suffix naming
mm unit assumptions
drawing scale vs table scale
curve sampling
S-JTSK coordinate convention
table insertion behavior
contour limitations
manual ribbon/CUI setup
basic troubleshooting
```

Do not overpromise Civil 3D level functionality.

## Development rules

1. Preserve AutoCAD LT compatibility first.
2. Keep the plugin usable without external services.
3. Keep generated entities on dedicated output layers.
4. Treat all model units as millimetres unless explicitly configured otherwise.
5. Keep settings user-editable through `CPSETTINGS`.
6. Keep CSV and DWG table output based on the same internal point records.
7. Avoid duplicating point extraction logic for CSV and table output.
8. Fail gracefully on unsupported entities.
9. Add or update tests whenever changing extraction, naming, table, scale, or contour logic.
10. Update README whenever adding or changing a setting.
11. Update `TODO.md` after each completed task so it reflects newly completed work, newly discovered follow-ups, and changed priorities.

## Suggested next development steps

### Step 1: Import current package into repository

Import the latest package structure into the repository root.

Recommended initial structure:

```text
dist/
  CadPoints.bundle/
src/
  CadPoints.bundle/
README.md
scripts/
  build_release.py
  release.py
  version.py
tests/
  run_static_tests.py
releases/
```

Keep the editable bundle source in `src/CadPoints.bundle/`. Generate `dist/CadPoints.bundle/` with `py scripts/release.py --package-only` as the package payload that feeds npm/GitHub Packages publishing. Use `py scripts/release.py` for the autoinstaller ZIP.

### Step 2: Add repeatable build script

Create a cross-platform release build script that:

1. reads version from one source of truth,
2. validates bundle structure,
3. creates `releases/CadPoints_LT_Plugin_vX_Y_Z.zip`,
4. ensures the ZIP root contains `CadPoints.bundle/` directly.

### Step 3: Add static test script

Add static checks before changing LISP behavior.

The static test should catch basic broken releases before runtime testing in AutoCAD LT.

### Step 4: Runtime test in AutoCAD LT

Open:

```text
CadPoints.bundle/Contents/Test/example_test.dxf
```

Load the bundle or LISP manually.

Run:

```text
CPSETTINGS
CPEXPORT
```

Then verify:

```text
CSV file exists
point names are correct
point entities are on CADPOINTS_POINTS
point labels are on CADPOINTS_POINT_LABELS
table is inserted to the right of max X
curve sampling uses 1000 mm by default
```

### Step 5: Fix runtime issues from AutoCAD LT

Expect possible issues around `vlax-curve-*` functions depending on AutoCAD LT behavior.

If a function is unavailable, add a safe fallback for the specific entity type.

Do not replace the whole architecture unless necessary.

## Communication rules for Codex

When making changes, report:

```text
files changed
commands added or changed
settings added or changed
tests run
test results
known limitations
```

After each task, update `TODO.md` before the final response. Mark completed items, add any follow-up work discovered during implementation, and remove or reword stale items when the project direction changes.

If AutoCAD LT runtime testing was not performed, state it explicitly.

Do not claim that runtime testing passed unless it was actually run in AutoCAD LT.
