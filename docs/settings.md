# CadPoints Settings Reference

## Commands

- `CPSETTINGS`
- `CPEXPORT`
- `CPHELP`

## Default Output Layers

- `CADPOINTS_POINTS`
- `CADPOINTS_POINT_LABELS`
- `CADPOINTS_TABLE`
- `CADPOINTS_CONTOURS`

## Core Settings

| Setting | Purpose | Default |
| --- | --- | --- |
| Source layers | Layers scanned for supported geometry | user-defined |
| CSV/table columns | Visible columns for export and drawn table | `POINT_NAME:Bod;LAYER:Hladina;ENTITY_TYPE:Objekt;VERTEX_NO:Vrchol;Y_SJTSK:Y S-JTSK;X_SJTSK:X S-JTSK;Z:Z` |
| Drawing scale | Used for labels and other drawing annotations | user-defined |
| Table scale | Used for the inserted table | user-defined |
| Point naming pattern | Custom point name format | empty, use layer suffix |
| Point output layer | Layer for generated `POINT` entities | `CADPOINTS_POINTS` |
| Point label output layer | Layer for point labels | `CADPOINTS_POINT_LABELS` |
| Point labels enabled | Turns point labels on or off | user-defined |
| Point label paper height | Label text height in paper millimetres | `2.5 mm` |
| Table insertion enabled | Turns the drawn table on or off | user-defined |
| Table paper text height | Table text height in paper millimetres | `2.5 mm` |
| Table paper offset | Offset to the right of max X in paper millimetres | `50 mm` |
| Table layer | Layer for the drawn table | `CADPOINTS_TABLE` |
| Contours enabled | Turns contour generation on or off | user-defined |
| Contour interval | Contour Z step in millimetres | `1000 mm` |
| Contour layer | Layer for contour output | `CADPOINTS_CONTOURS` |
| Contours as SPLINE | Prefer `SPLINE` output when possible | user-defined |
| Curve sampling enabled | Samples curved geometry by length | user-defined |
| Curve sampling interval | Sampling step in millimetres | `1000 mm` |

## Column Fields

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

## Naming Rules

- Empty pattern: use the source layer suffix after the last `_`.
- Pattern with `#`: each `#` is a numeric placeholder.
- Pattern without `#`: append a 3-digit counter.
- Pattern numbering is global unless the implementation explicitly changes it.

## Units

CadPoints assumes millimetre drawings:

```text
1 drawing unit = 1 mm
```

Paper millimetres are converted to model units using the active drawing scale or table scale.
