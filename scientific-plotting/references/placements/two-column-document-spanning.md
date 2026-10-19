# Spanning Placement in a Two-Column Document

This file applies to figures spanning both columns in a two-column document. Independent coordinate plots have the scoped preset below; other plot types have no default physical dimensions. Do not use the canvas or any coordinate positions from the full-width placement for a one-column document as defaults for this placement.

## 1. Independent Two-Dimensional Coordinate Plots

Applies to the [independent two-dimensional coordinate-plot workflow](../plot-types/independent-2d.md), without imposing a particular scientific plot family.

- Each internal plot box defaults to `60 mm × 45 mm`, excluding tick text, axis labels, legends, panel labels, and other surrounding text. Dimensions explicitly specified by the user override the corresponding fields. Use `PositionConstraint = 'innerposition'` and verify the actual box in the final PDF by measuring between the frame-line centers; each dimension must be within `0.1 mm` of its configured value. Aspect-ratio constraints must not silently reduce the actual drawing box.
- Default to one independent plot. When two plots are requested, arrange them from left to right in the specified input order. Each box retains its configured dimensions, and equal-sized boxes have aligned top and bottom borders. Keep each plot's complete coordinate labels and independently configured ranges; do not suppress labels or impose shared ranges merely because the plots are adjacent. More plots or another arrangement require an explicit task configuration.
- Measure all visible text in its final font, including negative tick values, subscripts, and any requested outside legends or annotations. Derive the four margins, the gap between two plots, and the complete canvas from those measured extents plus explicitly configured padding. Record the resulting dimensions in the task script and set the final PDF page size explicitly. Retain the common `Times New Roman`, `8 pt` main-text default; this preset has no fixed total width or height, and neither an approximately `70 mm` screenshot width nor a `148 mm` canvas is its default.
- Preserve the internal boxes and font size when more surrounding space is needed. Check the complete canvas against any known available width across both article columns. If the content and required padding exceed that limit, report the required and available widths and resolve the conflicting requirements with the user; do not shrink the boxes, reduce the font, clip text, or silently scale the exported figure to fit.
- All physical dimensions and font sizes refer to the exported file at its native size. Enlarging surrounding whitespace or placing two plots side by side does not enlarge the individual plot boxes.

## 2. Other Plot Types

For plot types other than independent coordinate plots, the following information sufficient to determine the layout must be obtained from the user's current instructions or a confirmed configuration before plotting:

- Canvas width and height;
- Internal width and height of each type of plot box;
- Arrangement of multiple plots and the necessary margins and gaps, or the complete position of each plot box.

## 3. MAT Sheared Slices

For MAT sheared slices, also obtain and explicitly configure the number of columns per row, width and height of each slice, downward drop, gap between slices, row gap where applicable, all four margins, complete canvas dimensions, and colorbar dimensions or an equivalent complete position. Explicitly set inapplicable gaps to `0`. Do not call the renderer if these fields are incomplete, because its omitted values correspond to the one-column document placement. Label, tick-text, title, and tick-mark offsets may start from the plot-type defaults but must be rechecked at the actual dimensions of this placement; explicitly override the corresponding offset fields if crowding or unbalanced proportions occur.

## 4. Dimension Overrides and Missing Information

Ask only about fields that remain undetermined and affect the layout. When the user provides complete coordinate positions, use those positions; once the dimensions are obtained, apply both the main workflow and the selected plot-type file's rules. Unless otherwise specified, independent coordinate plots use this file's internal plot-box preset, with the remaining dimensions calculated from the actual text. When dimensions for other plot types are incomplete, do not borrow another placement's presets to proceed with plotting.
