# CadPoints test files

## example_test.dwg

This package cannot generate a real DWG file outside AutoCAD. DWG is a proprietary binary format and the package is built here without AutoCAD runtime access.

A DXF fallback is included as `example_test.dxf`. Open it in AutoCAD LT and save it as DWG if you need a native DWG file.

Alternatively use `create_example_test.scr` in AutoCAD LT to create the test drawing, then save it as:

```text
example_test.dwg
```

## Defined input and expected output

`example_test.dxf` is the human-facing sample drawing.

For automated runtime verification, `cadpoints_runtime_smoke_test.lsp` creates a deterministic input directly in the current drawing:

- one `LINE` on `CP_POINTS_A`
- one 3-vertex `LWPOLYLINE` on `CP_POINTS_B`

The expected CSV output is stored in:

```text
expected_output.csv
```

The expected point names are:

```text
A001
A002
B001
B002
B003
```

## create_example_test.scr

Creates a small S-JTSK-like model-space drawing in millimetres with two source layers:

```text
CP_POINTS_A
CP_POINTS_B
```

Expected default point names:

```text
CP_POINTS_A -> A001, A002, ...
CP_POINTS_B -> B001, B002, ...
```

## cadpoints_smoke_test.lsp

Run this after loading `cadpoints.lsp`:

```text
APPLOAD
Contents/Test/cadpoints_smoke_test.lsp
CPTESTNAMES
```

Expected command-line output:

```text
CPTESTNAMES OK
```

## cadpoints_runtime_smoke_test.lsp

Run this in AutoCAD LT on `example_test.dxf` after loading `cadpoints.lsp`:

```text
APPLOAD
Contents/Test/cadpoints_runtime_smoke_test.lsp
CPFULLSMOKE
```

`CPFULLSMOKE` writes a small text result file and a CSV export. It verifies command definitions, source layers, generated point entities, generated point labels, table output, CSV output, and expected point name prefixes.

It also compares the generated CSV to `expected_output.csv`.
