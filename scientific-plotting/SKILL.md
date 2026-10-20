---
name: scientific-plotting
description: "Plot existing numerical data as one-dimensional bifurcation and Lyapunov exponent comparisons, independent 2D coordinate plots, pure time series, or paired phase trajectories and waveforms, or render existing MAT categorical planes as sheared slices; arrange, export, and verify figures for the target placement. Do not use for generating simulation data, modifying models, numerical solving, designing classification criteria, or analyzing dynamical mechanisms."
---

# Scientific Plotting Workflow

The user's current instructions and settings confirmed in the current conversation take precedence over this skill's defaults. Read and follow the applicable `AGENTS.md` instructions for the user's current working project, using the project and directory scope established by the host environment. Resolve these instructions from the working project rather than relative to the installed skill directory. If no applicable project instruction file exists, proceed under the other applicable instructions and this skill's defaults. The currently included plot types are one-dimensional bifurcation and Lyapunov exponent comparisons, independent 2D coordinate plots, pure time series, paired phase trajectories and waveforms, and sheared slices of MAT categorical planes. Establish a corresponding workflow before using any other plot type; do not apply rules specific to a similar plot type.

## 1. Plot Type and Placement Routing

For each task, determine the plot type first, then the final placement, and read exactly one corresponding file for each:

1. **Plot type**
   - One-dimensional bifurcation samples above Lyapunov exponent curves for comparison: read the [bifurcation and Lyapunov exponent comparison workflow](references/plot-types/bifurcation-lyapunov.md). One comparison group contains both panels; select this route when the exponent panel is requested together with the bifurcation plot.
   - Independent 2D coordinate plots, including high-density parameter-versus-state bifurcation scatter plots: read the [independent 2D workflow](references/plot-types/independent-2d.md) and apply any relevant scenario guidance within it. Select this route when the user requests the independent coordinate-plot format or a documented scenario, not merely because a figure has one panel. A standalone bifurcation scatter plot stays here; a bifurcation plot with an exponent panel uses the comparison route above. Discrete MAT category planes rendered as sheared slices still use the categorical-slice route below. Preserve an explicitly requested time-series, phase/waveform, or categorical-slice workflow and its presets.
   - Pure time series: read the [pure time-series workflow](references/plot-types/pure-time-series.md).
   - Paired plots with a phase trajectory on the left and a waveform on the right: read the [phase-trajectory-and-waveform workflow](references/plot-types/phase-waveform.md).
   - Sheared slices of MAT categorical planes: read the [MAT bifurcation and categorical-plane slice workflow](references/plot-types/mat-bifurcation-slices.md).
2. **Placement**
   - When the user explicitly specifies a placement, read the corresponding file.
   - When no placement is specified, default to [full width in a one-column document](references/placements/one-column-document-full-width.md).
   - For a figure occupying one column in a two-column document, read [one column in a two-column document](references/placements/two-column-document-single-column.md).
   - For a figure spanning both columns in a two-column document, read [spanning both columns in a two-column document](references/placements/two-column-document-spanning.md).
3. Physical dimensions explicitly provided in the user's current request override the corresponding default fields in the placement file; fields without overrides retain their existing presets. If the selected placement has no default dimensions, confirm the missing dimensions. Do not borrow values from another placement.

Color schemes are shared configuration across these two dimensions. Read the [color-scheme reference](references/color-schemes.md) when selecting curve or category colors. Use the selected scheme, or SailRain by default, unless explicit user colors or a confirmed task configuration override it. A scheme changes colors only; it does not change typography, geometry, colorbar placement, or export requirements.

## 2. Common Configuration and Input Principles

1. Inspect the original files, metadata, and applicable existing programs specified by the user directly. Do not substitute screenshots, historical outputs, or older data with similar names. Configure input fields, columns, matrix orientation, variables, units, figure count, and order from the actual source or confirmed instructions.
2. Centralize the configuration of inputs and their order, plot type, placement, display semantics, ranges, arrangement, dimensions, colors, text, and output location. Determine these from the original data, existing programs, and current conversation first. Ask only about information that cannot be verified and would affect the result.
3. Treat original data as read-only: do not overwrite, reorder, reformat, or delete it. By default, faithfully use the original samples or classification cells without interpolation, downsampling, smoothing, or changes to numerical values. Apply the validity and orientation checks in the selected plot-type file.
4. Do not infer variables, units, periods, attractors, or categories from filenames, numerical magnitudes, codes, or example colors. Identify discrepancies between conflicting sources. If semantics cannot be verified, confirm them first or, if the user accepts, faithfully use the original codes as labels.
5. Preserve the file and figure order specified by the user or confirmed in the current conversation. Do not automatically reorder by filename or numerical value.

## 3. Common Graphics and Implementation Rules

1. All visible text, including tick labels, axis labels, panel labels, parameter text, colorbar text, and any user-requested titles or legends, must use `Times New Roman`. Main text defaults to `8 pt`; subscripts may use a smaller size as needed for layout. Use another font size when explicitly specified by the user. Check font availability before rendering; report a missing font and resolve it before claiming typography acceptance. Do not silently substitute one.
2. Use the mathematical minus sign `−` (`U+2212`) for every displayed mathematical negative sign or subtraction, including negative ticks, unit and scientific-notation exponents, formulas, legends, and annotations. Read and apply the [shared typography rules](references/typography.md) for every plot type and placement. Change display strings only; preserve original numerical data, executable operators, identifiers, filenames, English hyphens, and range punctuation. Construct mathematical fragments from verified semantics rather than replacing hyphens throughout arbitrary text.
3. Use a white canvas by default. Italicize variables and subscripts that represent variables; use upright type for units and descriptive subscripts. Follow the user's requirements for specific symbols, capitalization, and glyphs.
4. Resolve colors using the [shared color-scheme rules](references/color-schemes.md) and the selected plot-type file. Preserve explicit user colors and confirmed task mappings; otherwise, use the selected scheme or the SailRain default. Record the scheme and actual color assignments in the task configuration. Do not transfer semantic meanings from historical figures, scheme provenance labels, or other datasets.
5. Retain reproducible MATLAB scripts. Construct paths with `mfilename('fullpath')` and explicit configuration rather than relying on manual directory changes. Use English names for new files, functions, and variables. Write new or modified comments, prompts, figure titles, and labels in American English, preserving mathematical symbols as required by the task.
6. Use output names specified by the user; otherwise, use English `snake_case` names that describe the figure content. Do not overwrite unrelated files with the same name; report conflicts first. Do not write real data or generated results into the installed skill directory.

## 4. Verification and Delivery

1. Run MATLAB to completion. Check input sources, display mappings, sample or classification-cell counts, and ranges to confirm that the figures faithfully represent the original data.
2. Verify positions and physical dimensions against the current plot type, placement, and user configuration. Explicitly specified millimeter dimensions must be accurate within `0.1 mm`. Perform the output, data, and visual checks required by the selected plot-type file; do not substitute another plot type's export formats.
3. Inspect a high-resolution rendering of the final acceptance files for fonts, font sizes, mathematical minus glyphs, colors, line widths, labels, boundaries, clipping, overlap, and unnecessary whitespace. Correct any issues, then export and inspect again.
4. Deliver the reproducible program and the final files required by the selected plot type. Briefly describe the plot type, placement, input and display mappings, user overrides, and output location. Report whether MATLAB ran successfully and which dimension, file, and visual checks were completed. Clearly disclose any verification that was not completed.
