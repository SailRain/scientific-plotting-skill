# Full-Width Placement in a One-Column Document

This file applies to full-width figures in a one-column document and is the default choice when the user does not specify a placement. These values are default presets for the current project, not universal standards for all one-column journals; dimensions explicitly provided by the user in the current turn override the corresponding preset fields.

## 1. Four Groups of Pure Time-Series Plots

Applies to four groups of pure time-series plots arranged in two columns and two rows.

- Unless the user specifies a different order, groups 1, 2, 3, and 4 occupy the upper-left, lower-left, upper-right, and lower-right positions, respectively.

- Canvas: `148 mm × 49 mm`
- Each internal plot box: `55 mm × 15 mm`
- Plot-box positions `[left, bottom, width, height]` (mm):

  ```text
  Left top:     [12, 27, 55, 15]
  Left bottom:  [12,  8, 55, 15]
  Right top:    [83, 27, 55, 15]
  Right bottom: [83,  8, 55, 15]
  ```

- If rounding of page coordinates in points produces an internal plot box of approximately `55.033 mm × 14.993 mm` in the final PDF, it passes under the main workflow's `0.1 mm` physical-dimension tolerance.

## 2. Four Groups of Phase Trajectory ＋ Waveform Plots

Applies to four groups arranged in two columns and two rows, with the phase trajectory and waveform in each group sharing a vertical axis.

- Unless the user specifies a different order, groups 1, 2, 3, and 4 occupy the upper-left, lower-left, upper-right, and lower-right positions, respectively.

```text
Canvas:             148 × 55 mm
Phase plot box:     16 × 16 mm
Gap within a pair:  3 mm
Waveform plot box:  41 × 16 mm
Pair origins:       [12, 33], [12, 8], [83, 33], [83, 8] mm
```

Each pair origin is the lower-left corner of the phase trajectory plot; the waveform origin is offset to the right by the phase plot width plus the gap within the pair.

## 3. Sheared Slices of MAT Bifurcation and Categorical Planes

Applies to existing MAT discrete categorical planes rendered using the sheared slice plot type.

- Horizontal width of each slice: `34.5 mm`
- Vertical height of each slice: `36 mm`
- Downward drop toward the right: `9.75 mm`
- Gap between slices: `2.25 mm`
- Gap between rows: `9.75 mm`
- Margins `[left, bottom, right, top]`: `[10.5, 5.25, 16.5, 4.5] mm`
- At most three slices per row; the default canvas for three slices is `135 mm × 55.5 mm`.
- With more than three slices, wrap to new rows in input order and derive the canvas automatically. When more categories, longer colorbar labels, or a multirow layout require more space, increase the canvas height using the existing algorithm rather than reducing the default `8 pt` text.
- The physical layout defaults in the [MAT renderer](../../scripts/render_bifurcation_slices.m) implement this one-column placement. The detailed millimeter offsets for labels, ticks, and the colorbar are also part of this default implementation; these detailed positions must be rechecked after the user overrides the main layout fields.

## 4. Plot Counts or Arrangements Outside the Presets

- When the plot count, arrangement, vertical-axis display, or text space for time-domain plots does not match the presets above, retain the preset canvas dimensions for the corresponding plot type and recalculate the plot boxes, margins, and gaps; do not mechanically apply the four-group coordinates.
- When MAT slices do not match the three-slice, single-row preset, recalculate the number of rows and the canvas using this placement's rule of at most three columns; increase the height automatically only when category labels or multirow content actually require it.
- Any revised layout must preserve the structural requirements in the selected plot-type file and the font, readability, and no-clipping requirements in the main workflow.
- If time-domain plots cannot achieve a clear layout without overlap or clipping within the preset canvas, report the conflict and ask the user for new dimensions; do not silently enlarge or shrink the canvas. For MAT slices, only the established automatic derivation and height increases described above are allowed; other dimension changes still require confirmation.
