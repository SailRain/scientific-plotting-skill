# Full-Width Placement in a One-Column Document

This file applies to full-width figures in a one-column document and is the default choice when the user does not specify a placement. These values are this skill's bundled defaults, not universal standards for all one-column journals; dimensions explicitly provided by the user in the current turn override the corresponding preset fields.

## 1. Pure Time-Series Plots

Applies to the [pure time-series workflow](../plot-types/pure-time-series.md).

- Every internal plot box defaults to `60 mm` wide. If the entire figure contains exactly one panel and exactly one data waveform, its default height is `12 mm`; otherwise, multiple data waveforms or multiple panels make every box's default height `15 mm`. A user-specified width or height overrides only that corresponding field. These dimensions exclude tick labels, axis labels, legends, panel labels, and external annotations. Use `PositionConstraint = 'innerposition'` and measure between frame-line centers in the final PDF; each dimension must be within `0.1 mm` of its configured value.
- Default to one vertical plot column, preserving the specified panel order from top to bottom. Use two plot columns only when requested. For `N` panels in two columns, put the first `ceil(N / 2)` panels from top to bottom in the left column and the remaining panels from top to bottom in the right column. Align the frames in corresponding rows; an odd panel count must not create an empty axes object for the unoccupied cell. Do not automatically reorder panels.
- Apply the plot-type file's `each-panel`, `shared-bottom`, or `hidden` horizontal-axis text mode. A single panel defaults to `each-panel`; multiple panels with identical time ranges and ticks default to `shared-bottom`. In two plot columns, `shared-bottom` shows complete horizontal-axis text on the last occupied panel of each column. Do not share horizontal-axis text when the required time ranges or ticks differ. The vertical-axis mode defaults to `single-y`; use `split-y` only when explicitly requested with a confirmed curve-to-axis mapping.
- Measure all visible text in its final font, including left and right tick labels, axis labels, panel labels, and any requested legends or external annotations. Derive the four margins, vertical gaps, any horizontal gap, and complete canvas from these extents plus explicitly configured padding. Reserve complete horizontal-axis text wherever required by the selected mode, and use common row geometry to preserve frame alignment in two plot columns. Record the resulting dimensions in the task script and set an explicit PDF page size; this preset has no fixed canvas or hard-coded coordinates.
- Retain the configured internal frames and the common `Times New Roman`, `8 pt` main-text default when more surrounding space is needed. `split-y` adds the necessary space for right-axis text without changing the frame dimensions. Check the complete canvas against any known available article width; if the content and required padding exceed it, report the required and available widths and resolve the conflict with the user. Do not stretch or shrink frames, reduce the font, clip text, or silently scale the figure to fit. If no width is known, report the native canvas dimensions.
- All physical dimensions and font sizes refer to the exported file at its native size. Additional panels or plot columns change the surrounding layout, not the configured frame dimensions.

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

## 4. Independent Two-Dimensional Coordinate Plots

Applies to the [independent two-dimensional coordinate-plot workflow](../plot-types/independent-2d.md), without imposing a particular scientific plot family.

- Each internal plot box defaults to `60 mm × 45 mm`, excluding tick text, axis labels, legends, panel labels, and other surrounding text. Dimensions explicitly specified by the user override the corresponding fields. Use `PositionConstraint = 'innerposition'` and verify the actual box in the final PDF by measuring between the frame-line centers; each dimension must be within `0.1 mm` of its configured value. Aspect-ratio constraints must not silently reduce the actual drawing box.
- Default to one independent plot. When two plots are requested, arrange them from left to right in the specified input order. Each box retains its configured dimensions, and equal-sized boxes have aligned top and bottom borders. Keep each plot's complete coordinate labels and independently configured ranges; do not suppress labels or impose shared ranges merely because the plots are adjacent. More plots or another arrangement require an explicit task configuration.
- Measure all visible text in its final font, including negative tick values, subscripts, and any requested outside legends or annotations. Derive the four margins, the gap between two plots, and the complete canvas from those measured extents plus explicitly configured padding. Record the resulting dimensions in the task script and set the final PDF page size explicitly. Retain the common `Times New Roman`, `8 pt` main-text default; this preset has no fixed total width or height, and neither an approximately `70 mm` screenshot width nor the other workflows' `148 mm` canvas is its default.
- Preserve the internal boxes and font size when more surrounding space is needed. Check the complete canvas against any known available article width. If the content and required padding exceed that limit, report the required and available widths and resolve the conflicting requirements with the user; do not shrink the boxes, reduce the font, clip text, or silently scale the exported figure to fit.
- All physical dimensions and font sizes refer to the exported file at its native size. Enlarging surrounding whitespace or placing two plots side by side does not enlarge the individual plot boxes.

## 5. One-Dimensional Bifurcation and Lyapunov Exponent Comparisons

Applies to the [one-dimensional bifurcation and Lyapunov exponent comparison workflow](../plot-types/bifurcation-lyapunov.md). Each comparison group contains a bifurcation plot above a Lyapunov exponent plot.

- The upper internal plot box defaults to `60 mm × 30 mm`; the lower internal plot box defaults to `60 mm × 15 mm`. These dimensions exclude tick text, axis labels, legends, panel labels, and other surrounding text. Dimensions explicitly specified by the user override the corresponding fields. Align the upper and lower frames on their left and right borders; resolve any conflict between explicit dimensions and the requested alignment. Use `PositionConstraint = 'innerposition'` and measure each actual box between the frame-line centers in the final PDF, within `0.1 mm` of each configured dimension. Aspect-ratio constraints must not silently reduce the actual drawing boxes.
- Default to one comparison group. When two groups are requested, arrange them from left to right in the specified input order, with the two upper boxes aligned and the two lower boxes aligned. Each group retains its own configured coordinate ranges; adjacency does not impose shared ranges between groups. More groups or another arrangement require an explicit task configuration.
- Apply the plot-type file's conditions for sharing the horizontal axis within each group. When those conditions hold, reserve horizontal-axis text only below the lower box. Otherwise reserve complete horizontal-axis text below both boxes. Keep the two vertical axes independently labeled and configured.
- Measure all visible text in its final font, including negative tick values, subscripts, and any requested outside legends or annotations. Derive the vertical gap within each group, any horizontal gap between groups, the four margins, and the complete canvas from those extents plus explicitly configured safety padding. For two groups, choose common vertical geometry that accommodates both groups' text while maintaining the frame alignments. Record the resulting dimensions in the task script and set the final PDF page size explicitly. Retain the common `Times New Roman`, `8 pt` main-text default; no fixed canvas or gap is inferred from a screenshot or borrowed from another plot type.
- Preserve the internal boxes and font size when more surrounding space is needed. Check the complete canvas against any known available article width. If the content and required padding exceed that limit, report the required and available widths and resolve the conflict with the user; do not shrink the boxes, reduce the font, clip text, or silently scale the exported figure to fit. If the available width is unknown, report the final native canvas dimensions rather than promising that all possible labels fit a particular column.
- All physical dimensions and font sizes refer to the exported file at its native size. Enlarging surrounding whitespace or placing two groups side by side does not enlarge the individual plot boxes.

## 6. Plot Counts or Arrangements Outside the Presets

- For pure time-series plots, retain each configured internal frame and derive the surrounding geometry under Section 1. Do not apply a fixed canvas or the phase/waveform coordinates to this plot type.
- When the plot count, arrangement, vertical-axis display, or text space for phase/waveform plots does not match the preset above, retain its preset canvas dimensions and recalculate the plot boxes, margins, and gaps; do not mechanically apply the four-group coordinates.
- When MAT slices do not match the three-slice, single-row preset, recalculate the number of rows and the canvas using this placement's rule of at most three columns; increase the height automatically only when category labels or multirow content actually require it.
- For independent coordinate plots, retain each configured internal box and calculate the surrounding geometry under Section 4. Do not apply the phase/waveform workflow's fixed-canvas rule to this plot type.
- For bifurcation and Lyapunov exponent comparisons, retain each configured upper and lower internal box and calculate the surrounding geometry under Section 5. Do not apply the phase/waveform workflow's fixed-canvas rule to this plot type.
- Any revised layout must preserve the structural requirements in the selected plot-type file and the font, readability, and no-clipping requirements in the main workflow.
- If phase/waveform plots cannot achieve a clear layout without overlap or clipping within the preset canvas, report the conflict and ask the user for new dimensions; do not silently enlarge or shrink the canvas. For MAT slices, only the established automatic derivation and height increases described above are allowed; other dimension changes still require confirmation.
