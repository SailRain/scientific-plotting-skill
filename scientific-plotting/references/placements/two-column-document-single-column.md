# Single-Column Placement in a Two-Column Document

This file applies to figures that occupy one column in a two-column document without spanning both columns. Exact dimensions or complete coordinate positions provided by the user take precedence over the corresponding defaults in this file. Apart from the pure time-series preset below, no default physical dimensions currently exist for other plot types; do not borrow the canvas, plot boxes, or coordinate positions from the full-width placement for a one-column document.

## 1. Pure Time-Series Plots

- Unless the user provides exact overriding dimensions in the current turn, each axis's internal plot box is fixed at `60 mm × 12 mm`, excluding tick text, axis labels, panel labels, and other surrounding text. Use `PositionConstraint = 'innerposition'` and verify the internal plot-box width and height in the final PDF with a tolerance of `0.1 mm`.
- Arrange one or more panels vertically in a single column; all internal plot boxes must have equal widths and aligned left and right borders, preserving the order specified by the user or the input data. Do not change to multiple columns or reorder panels without a user request.
- Use the `each-panel`, `shared-bottom`, or `hidden` horizontal-axis text mode defined in the plot-type file. A single panel defaults to `each-panel`; multiple panels with identical time ranges and ticks default to `shared-bottom`. The vertical-axis mode defaults to `single-y`; use `split-y` only after the user explicitly requests separate axes for multiple variables and confirms the left/right axis mapping.
- Obtain the actual extents of the tick text, xlabel, left and right y-labels, panel labels, and all other visible text in the final font, and use them to calculate the four margins and the vertical gaps between adjacent panels. `each-panel` must reserve space for each panel's complete horizontal-axis text; `shared-bottom` reserves space for complete horizontal-axis text only at the bottom; use `hidden` only when an external shared horizontal axis already exists or the user explicitly requests it.
- Calculate the complete canvas from the panel count, horizontal-axis text mode, vertical-axis mode, and all actual text extents, and set an explicit page width and height for the final PDF. Do not rely on automatic tight cropping to determine the page dimensions, or hard-code gaps inferred from screenshots.
- When space is insufficient, do not shrink the `60 mm × 12 mm` internal plot boxes, reduce the default `8 pt` font specified in the main workflow, or tolerate text clipping or overlap; enlarge the necessary surrounding space. If the target column width imposes an additional hard limit that cannot be satisfied simultaneously, report the conflict and obtain new dimension requirements.
- `split-y` adds only outer whitespace on the right and does not change the `60 mm × 12 mm` internal plot box. Handle the variables, units, ranges, and ticks on the left and right axes according to the plot-type file and the user-confirmed configuration.

## 2. Other Plot Types

For plot types other than pure time series, the following information sufficient to determine the layout must be obtained from the user's current instructions or a confirmed configuration before plotting:

- Canvas width and height;
- Internal width and height of each type of plot box;
- Arrangement of multiple plots and the necessary margins and gaps, or the complete position of each plot box.

## 3. MAT Sheared Slices

For MAT sheared slices, also obtain and explicitly configure the number of columns per row, width and height of each slice, downward drop, gap between slices, row gap where applicable, all four margins, complete canvas dimensions, and colorbar dimensions or an equivalent complete position. Explicitly set inapplicable gaps to `0`. Do not call the renderer if these fields are incomplete, because its omitted values correspond to the one-column document placement. Label, tick-text, title, and tick-mark offsets may start from the plot-type defaults but must be rechecked at the actual dimensions of this placement; explicitly override the corresponding offset fields if crowding or unbalanced proportions occur.

## 4. Dimension Overrides and Missing Information

Ask only about fields that remain undetermined and affect the layout. When the user provides exact dimensions or complete coordinate positions, follow the user's current requirements; once the dimensions are obtained, apply both the main workflow and the selected plot-type file's rules. Unless otherwise specified, pure time-series plots use this file's internal plot-box preset, with the remaining dimensions calculated from the actual text; when dimensions for other plot types are incomplete, do not borrow another placement's presets to proceed with plotting.
