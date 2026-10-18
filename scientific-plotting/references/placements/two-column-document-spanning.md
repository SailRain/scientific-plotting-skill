# Spanning Placement in a Two-Column Document

This file applies to figures spanning both columns in a two-column document. There are currently no default physical dimensions; do not use the canvas or any coordinate positions from the full-width placement for a one-column document as defaults for this placement.

Before plotting, the following information sufficient to determine the layout must be obtained from the user's current instructions or a confirmed configuration:

- Canvas width and height;
- Internal width and height of each type of plot box;
- Arrangement of multiple plots and the necessary margins and gaps, or the complete position of each plot box.

For MAT sheared slices, also obtain and explicitly configure the number of columns per row, width and height of each slice, downward drop, gap between slices, row gap where applicable, all four margins, complete canvas dimensions, and colorbar dimensions or an equivalent complete position. Explicitly set inapplicable gaps to `0`. Do not call the renderer if these fields are incomplete, because its omitted values correspond to the one-column document placement. Label, tick-text, title, and tick-mark offsets may start from the plot-type defaults but must be rechecked at the actual dimensions of this placement; explicitly override the corresponding offset fields if crowding or unbalanced proportions occur.

Ask only about fields that remain undetermined and affect the layout. When the user provides complete coordinate positions, use those positions; once the dimensions are obtained, apply both the main workflow and the selected plot-type file's rules. When dimensions are incomplete, do not borrow another placement's presets to proceed with plotting.
