# CadPoints for AutoCAD LT

LT-compatible AutoLISP bundle for exporting named point coordinates from selected layers, generating POINT entities and labels in separate layers, sampling curved geometry, inserting a configurable point table into the DWG, and optionally generating approximate contour curves from Z coordinates.

## Version

```text
0.6.2
```

## Download

Latest release ZIP:

- [`CadPoints_LT_Plugin_v0_6_2.zip`](releases/CadPoints_LT_Plugin_v0_6_2.zip)

## Supported AutoCAD

- AutoCAD LT 2024+
- Windows deployment via `.bundle` under Autodesk `ApplicationPlugins`

## Installation

For the release ZIP, double-click `install_windows.bat` in the archive root.

If you work from the repository checkout, the source installer lives in `scripts\install_windows.bat`.

Copy the whole folder:

```text
CadPoints.bundle
```

to one of these folders:

```text
%APPDATA%\Autodesk\ApplicationPlugins
```

or, for all users:

```text
%PROGRAMDATA%\Autodesk\ApplicationPlugins
```

The `dist/` folder is the generated package payload used for npm/GitHub Packages publishing.
The `releases/` folder is tracked in the repository and contains the autoinstaller ZIP artifacts for each published version.

Restart AutoCAD LT.

For developer notes, build/release instructions, and the runtime test workflow, see:

```text
docs/development.md
docs/settings.md
```

Release note: bump the version before each release with `pnpm version:patch` (or `minor`/`major` as appropriate) and keep the versioned files in sync before running the packaging scripts.
pnpm-first package commands are available via `pnpm check`, `pnpm package:dist`, `pnpm build:autoinstaller`, `pnpm release`, and `pnpm release:check`.
Use `pnpm package:dist` to prepare the npm/GitHub Packages payload in `dist/`, and `pnpm build:autoinstaller` or `pnpm release` to create the installer ZIP in `releases/`.

## Commands

```text
CPSETTINGS
```

Configures:

- source layers, comma-separated, for example `CP_POINTS_A,CP_POINTS_B`
- decimal precision
- CSV/DWG table columns
- drawing scale: `1:25`, `1:50`, `1:100`, `1:500`, or `1:1000`
- point name pattern, for example `A-SO01-###`
- generated POINT entities in a separate layer
- point layer, default `CADPOINTS_POINTS`
- point labels in a separate layer
- label paper text height, default `2.5` mm on paper
- label layer, default `CADPOINTS_POINT_LABELS`
- whether to insert a point table into the drawing
- table scale: `1:25`, `1:50`, `1:100`, `1:500`, or `1:1000`
- table paper offset to the right from the maximum X coordinate, default `50` mm on paper
- table paper text height, default `2.5` mm on paper
- table layer
- optional contour generation from Z coordinates
- contour Z interval, default `1000` mm
- contour layer
- whether contours should be generated as SPLINE entities where possible
- whether curved geometry should be sampled by length
- curve sampling interval, default `1000` mm

```text
CPEXPORT
```

Exports all supported objects from configured layers to CSV.

Supported entities:

```text
LINE
LWPOLYLINE
POLYLINE
ARC
CIRCLE
ELLIPSE
SPLINE
```

Straight `LINE` objects and straight polylines are exported by their real endpoints / vertices. Curved geometry is sampled by length when curve sampling is enabled.

If table insertion is enabled, the command also inserts a drawn point table into the DWG. The table is placed to the right of the rightmost exported point:

```text
table insertion X = maximum exported point X + configured paper offset * configured table scale
```

Default table placement at scale `1:100`:

```text
paper offset = 50 mm
model offset = 50 * 100 = 5000 mm
```

If contour generation is enabled, the command also generates approximate contour curves into the configured contour layer.

```text
CPHELP
```

Shows command summary.

## Drawing units and table scale

CadPoints assumes that the DWG is drawn in millimetres. All model-space values are therefore treated as millimetres unless changed manually.

Default millimetre-based values:

```text
curve sampling interval = 1000 mm
contour interval        = 1000 mm
point label height      = 250 mm
```

Point labels are controlled by drawing scale. The inserted table is controlled by table scale. Both scales use the same allowed scale values:

```text
1:25
1:50
1:100
1:500
1:1000
```

Internally, label height, table text height and right-side table offset are converted from paper millimetres to model millimetres:

```text
label model value = label paper value * drawing scale
table model value = table paper value * table scale
```

Example for scale `1:100`:

```text
table paper text height = 2.5 mm
table model text height = 250 mm

table paper offset = 50 mm
table model offset = 5000 mm
```


## Point naming and generated point layers

CadPoints can generate real `POINT` entities and text labels for every exported point. These outputs are intentionally separated from the source geometry.

Default output layers:

```text
generated POINT entities = CADPOINTS_POINTS
generated point labels   = CADPOINTS_POINT_LABELS
```

When the point name pattern is empty, the point prefix is taken from the source layer suffix after the last underscore.

Example:

```text
source layer CP_POINTS_A -> A001, A002, A003
source layer CP_POINTS_B -> B001, B002, B003
```

The numbering counter is independent for each suffix.

You can override this with a custom pattern in `CPSETTINGS`. Every `#` character in the first hash run is replaced with a zero-padded number.

Example:

```text
A-SO01-### -> A-SO01-001, A-SO01-002, A-SO01-003
P-####     -> P-0001, P-0002, P-0003
```

When a custom pattern is used, numbering uses one shared sequence for that pattern.

## Configurable CSV/table columns

The same column configuration is used for CSV export and for the inserted DWG table.

Default configuration:

```text
POINT_NAME:Bod;LAYER:Hladina;ENTITY_TYPE:Objekt;VERTEX_NO:Vrchol;Y_SJTSK:Y S-JTSK;X_SJTSK:X S-JTSK;Z:Z
```

Format:

```text
FIELD_ID:Visible column name;FIELD_ID:Visible column name
```

Available field IDs:

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

### Example: hide layer column

```text
POINT_NAME:Bod;ENTITY_TYPE:Objekt;VERTEX_NO:Vrchol;Y_SJTSK:Y;X_SJTSK:X;Z:Z
```

### Example: rename columns for staking-out table

```text
POINT_NAME:Cislo bodu;Y_SJTSK:S-JTSK Y;X_SJTSK:S-JTSK X;Z:Vyska
```

### Example: include AutoCAD handle

```text
POINT_NAME:Bod;HANDLE:Handle;Y_SJTSK:Y S-JTSK;X_SJTSK:X S-JTSK;Z:Z
```

## S-JTSK coordinates

The plugin does not transform coordinates. It assumes that the current DWG is already drawn in S-JTSK or in the coordinate convention used by the project.

The default coordinate mapping is:

```text
Y_SJTSK = point X value from DWG
X_SJTSK = point Y value from DWG
Z       = point Z value from DWG, or 0.000 when missing
```

This is intentional because many Czech CAD workflows store S-JTSK coordinates in DWG as X/Y drawing coordinates but label them as Y/X in survey notation.

If your office uses the opposite convention, swap the values in `cp:field-value` inside:

```text
Contents\LISP\cadpoints.lsp
```

## Curve sampling

Curve sampling is controlled by `CPSETTINGS`.

Relevant settings:

```text
Vzorkovat oblouky, spliny a krivky po delce? [Ano/Ne]
Krok vzorkovani krivek ve vykresovych jednotkach
```

Default interval:

```text
1000
```

With drawings in millimetres, this means one generated point approximately every 1 m along the curve.

The following geometry is sampled when enabled:

- `ARC`
- `CIRCLE`
- `ELLIPSE`
- `SPLINE`
- `LWPOLYLINE` with bulge / arc segments
- curve-like old `POLYLINE` entities when AutoCAD exposes them through curve functions

Closed curves, such as circles, do not duplicate the closing point. Open curves include both start and end points.

The sampled points are included in:

- CSV export
- inserted DWG point table
- optional point labels
- optional contour interpolation source segments

Important: sampling is based on drawing units. Because the project default is millimetres, the default interval is `1000`.

## Optional contour generation

Contour generation is controlled by `CPSETTINGS`.

Relevant settings:

```text
Vykreslit interpolovane vrstevnice podle Z? [Ano/Ne]
Interval vrstevnic Z
Hladina vrstevnic
Kreslit vrstevnice jako SPLINE? [Ano/Ne]
```

Default contour interval and layer:

```text
CONTOUR_INTERVAL = 1000 mm
CONTOUR_LAYER    = CADPOINTS_CONTOURS
```

### How contours are generated

The plugin uses the exported geometry and sampled curve points as source segments:

- `LINE`: one segment between start and end point
- `LWPOLYLINE`: segment between each pair of neighboring vertices
- closed `LWPOLYLINE`: also segment between last and first vertex
- `POLYLINE`: segment between each pair of neighboring vertices
- closed `POLYLINE`: also segment between last and first vertex
- sampled curves: segment between each pair of neighboring sampled points

For each configured Z level, the plugin finds intersections where source segments cross that Z level. It then sorts those interpolated points by X/Y and draws one curve for that Z level.

When spline mode is enabled, it tries to create `SPLINE` entities. If that fails or if there are only two points, it falls back to `LWPOLYLINE`.

### Important limitation

This is not a real terrain model and not a TIN triangulation. It is an approximate interpolation over existing source segments. It is suitable as a helper output for simple line/polygon inputs, but it should not be treated as a certified geodetic contour model.

For precise terrain contours, the correct workflow would be:

```text
points -> TIN / surface model -> contour extraction
```

That level is better handled by Civil 3D, full AutoCAD with a stronger plugin API, or a dedicated geodetic/GIS tool.

## Test drawing and smoke test

The package includes test assets under:

```text
Contents/Test
```

Included files:

```text
example_test.dxf
create_example_test.scr
cadpoints_smoke_test.lsp
README_TEST.md
```

A native `example_test.dwg` is not generated in this package because DWG writing requires AutoCAD or another licensed DWG runtime. Open `example_test.dxf` in AutoCAD LT and save it as `example_test.dwg`, or run `create_example_test.scr` and save the resulting drawing.

Smoke test for point naming:

```text
APPLOAD cadpoints.lsp
APPLOAD Contents/Test/cadpoints_smoke_test.lsp
CPTESTNAMES
```

Expected output:

```text
CPTESTNAMES OK
```

## Ribbon / panel setup

A ready binary `.cuix` is not included. In AutoCAD LT it is safer to create the partial ribbon/panel directly through the built-in `CUI` editor, because AutoCAD stores workspace-specific ribbon data inside CUIx customization files.

The bundle includes prepared icon files and a legacy menu template:

```text
Contents\Menu\cadpoints.mnu
Contents\Resources\cp-export.bmp
Contents\Resources\cp-settings.bmp
Contents\Resources\cp-help.bmp
Contents\Resources\cp-export-16.bmp
Contents\Resources\cp-settings-16.bmp
Contents\Resources\cp-help-16.bmp
```

### Create ribbon panel manually

1. Start AutoCAD LT.
2. Run command:

```text
CUI
```

3. In the left tree, expand:

```text
Ribbon > Panels
```

4. Create a new panel:

```text
CadPoints
```

5. In the command list, create these three custom commands.

### Command: CadPoints Export

Name:

```text
CadPoints Export
```

Macro:

```text
^C^C_CPEXPORT
```

Large image:

```text
Contents\Resources\cp-export.bmp
```

Small image:

```text
Contents\Resources\cp-export-16.bmp
```

### Command: CadPoints Settings

Name:

```text
CadPoints Settings
```

Macro:

```text
^C^C_CPSETTINGS
```

Large image:

```text
Contents\Resources\cp-settings.bmp
```

Small image:

```text
Contents\Resources\cp-settings-16.bmp
```

### Command: CadPoints Help

Name:

```text
CadPoints Help
```

Macro:

```text
^C^C_CPHELP
```

Large image:

```text
Contents\Resources\cp-help.bmp
```

Small image:

```text
Contents\Resources\cp-help-16.bmp
```

6. Drag the three commands into the new `CadPoints` panel.
7. Drag the `CadPoints` panel into an existing ribbon tab, for example:

```text
Ribbon > Tabs > Home - 2D
```

8. Click `Apply` and then `OK`.

## Alternative toolbar import

The file below can be used as a legacy menu/toolbar starting point:

```text
Contents\Menu\cadpoints.mnu
```

Depending on AutoCAD LT version and profile settings, import it through the CUI transfer tools or convert it into a partial customization file and load it through:

```text
CUILOAD
```

For daily use, the manual `CUI` ribbon setup above is more predictable.

## Troubleshooting

- If the bundle does not autoload, confirm that `CadPoints.bundle` is copied into `%APPDATA%\Autodesk\ApplicationPlugins` and restart AutoCAD LT.
- If `CPEXPORT` returns no points, check the configured source layers in `CPSETTINGS` and make sure the drawing actually contains matching geometry on those layers.
- If labels or the table look too large or too small, check `drawing scale` and `table scale`; they are separate settings.
- If curve sampling fails on a specific object type, the entity may not expose the curve functions required by AutoCAD LT. The bundle should report the unsupported type or handle and continue gracefully.
- If contour output looks wrong, remember that CadPoints produces approximate contours from existing segments, not a Civil 3D terrain surface.

### Quick Diagnostics

Use these commands in AutoCAD LT to narrow down where the problem is:

```text
APPAUTOLOAD
APPAUTOLOADER
APPLOAD
TRUSTEDPATHS
```

What to check:

- `APPAUTOLOAD` should normally allow plug-ins to load. If it is `0`, plug-ins will not load automatically.
- `APPAUTOLOADER` shows whether AutoCAD LT can see the installed plug-ins and can force a reload.
- `APPLOAD` can be used to load `CadPoints.bundle\Contents\LISP\cadpoints.lsp` manually for a one-session test.
- `TRUSTEDPATHS` matters if secure mode blocks the bundle or the LISP file.

If the commands still do not appear after a restart:

1. Verify the bundle is located at `%APPDATA%\Autodesk\ApplicationPlugins\CadPoints.bundle`.
2. Verify `PackageContents.xml` exists directly inside that folder.
3. Run `APPAUTOLOADER` and check whether CadPoints is listed.
4. If needed, load `CadPoints.bundle\Contents\LISP\cadpoints.lsp` manually with `APPLOAD` and test `CPSETTINGS` and `CPEXPORT`.
