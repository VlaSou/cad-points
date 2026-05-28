# CadPoints test files

## example_test.dwg

This package cannot generate a real DWG file outside AutoCAD. DWG is a proprietary binary format and the package is built here without AutoCAD runtime access.

A DXF fallback is included as `example_test.dxf`. Open it in AutoCAD LT and save it as DWG if you need a native DWG file.

Alternatively use `create_example_test.scr` in AutoCAD LT to create the test drawing, then save it as:

```text
example_test.dwg
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
