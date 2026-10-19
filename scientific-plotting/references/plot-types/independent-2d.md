# Independent 2D Coordinate Plot Workflow

Read this file when the user requests an independent two-dimensional coordinate plot or one of its documented rendering scenarios, including high-density bifurcation scatter plots. This workflow provides a general framework with scenario-specific guidance; a plot may contain one or more series drawn with lines, markers, or both. Also apply the [main workflow](../../SKILL.md) and the selected placement file; physical plot-box dimensions and single or side-by-side arrangements belong to that placement.

## 1. Existing Data and Display Configuration

- Inspect the specified source files, metadata, and existing programs. Configure each series' paired x/y fields, units, sample order, line or marker representation, and identity from those sources or the user's instructions. Do not assume a fixed file format, variable name, scientific meaning, or equation from an example image.
- Check paired lengths and the validity of plotted coordinates. Keep source-defined gaps as gaps; do not connect across missing segments, interpolate, smooth, downsample, or sort by x. Nonmonotonic x values can be valid in a parametric curve. Preserve the original pairing and connection order.
- Keep each plot's ranges and ticks independent, even when two plots are placed side by side. Show complete x- and y-axis tick labels, variables, and units on each plot; do not hide the right plot's y-axis text or link ranges merely because the plots look similar.
- Honor explicit axis ranges, scales, and any data-selection conditions. If a specified range clips data without a requested local view, report it. With no specified ranges, cover the actual displayed data with modest padding, approximately 3% of each nonzero span on linear axes; use a readable range appropriate to the magnitude and units for a constant coordinate. For logarithmic axes, calculate padding in log space with limits valid for the supplied data and requested scale; report incompatible data/scale combinations rather than discarding data or applying arithmetic padding that invalidates a limit. Do not enlarge ranges just to obtain round ticks.
- Keep scientific interpretations, classification design, model solving, and simulation outside this workflow. Use a task-specific reproducible MATLAB script, as in the existing line-plot workflows; no separate general renderer is bundled.

## 2. Axes, Typography, and Optional Annotations

- Use a white background, black axes and text, a four-sided box, inward ticks, and no grid by default. Start with a `0.35 pt` box line width and `TickLength = [0.008, 0.008]`. Use the user's explicitly specified styles when provided.
- Apply the main workflow's Times New Roman and default `8 pt` main text to ticks, axis labels, parameter text, panel labels, and any requested titles or legends. Set `FontUnits = 'points'` and label/title font-size multipliers to `1` so MATLAB does not enlarge some text automatically. Subscripts may be smaller as needed; variables are italic and units and descriptive subscripts are upright.
- Set `PositionConstraint = 'innerposition'` and configure the internal plot box in physical units. Keep automatic data and plot-box aspect ratios unless the user requires otherwise; `axis equal`, `axis square`, or a manual aspect ratio must not silently change the physical box required by the placement. Report incompatible range, aspect-ratio, and dimension constraints.
- Configure line widths, markers, and series identities explicitly. For otherwise unspecified series colors, follow the [shared color rules](../color-schemes.md) and reuse the scheme's ordered `waveform_colors` as the general series palette; the field name does not assign time-domain meaning to these data. Preserve each identity's color across plots and resolve additional distinct colors through the shared rules.
- Add titles, legends, formulas, arrows, and other annotations only when requested or supplied in the confirmed task configuration. Reference images establish geometry only unless the user also requests their styling or content. Do not copy example equations, stability markers, colors, or legend text into unrelated plots.
- A standalone plot does not require a panel label. When labels are requested, preserve their confirmed text and plot mapping, place them in actual empty space, and avoid obscuring data or expanding axis ranges to accommodate them.

### High-Density Bifurcation Scatter Plots

Use this scenario for existing paired parameter values and retained state samples displayed as a dense point cloud. These are coordinate samples, not the discrete category cells or sheared planes handled by the MAT classification-slice workflow. The following is a starting combination for this scenario only; it does not set marker defaults for other independent curves or scatter plots. Explicit user styles take precedence.

```matlab
plot(ax, xValues, yValues, ...
    'LineStyle', 'none', ...
    'Marker', 'o', ...
    'MarkerSize', 0.20, ...
    'MarkerFaceColor', seriesColor, ...
    'MarkerEdgeColor', 'none');
```

- `xValues` and `yValues` are the complete, verified paired coordinate vectors from the existing data. Resolve `seriesColor` through the existing shared color rules; do not introduce a fixed color for bifurcation scatter plots.
- Start with `MarkerSize = 0.20` pt, filled circles, no marker edges, and no connecting lines. Adjust the marker size using the actual internal plot box, local overlap density, and visibility in the final native-size PDF and its high-resolution rendering. Do not determine marker size mechanically from total point count or introduce point-count thresholds. Record the final size and the visual reason for any adjustment.
- Preserve every supplied sample, including repeated coordinates, and its parameter-to-state pairing. Do not downsample, deduplicate, or use a restricted `MarkerIndices` selection to hide samples. Do not connect the points or generate new simulation data to replace the supplied samples.
- The user reported an approved logistic map bifurcation example using this combination in a `60 mm × 45 mm` internal plot box with `6000` parameter values and `400` retained samples per parameter. This is user-provided experience, not a repository-reproduced test or a test run during this documentation update. Its point count, matrix shape, and frame dimensions are not prerequisites for this scenario; continue to obtain geometry from the selected placement and any user overrides.
- The example uses `plot`, whose [MarkerSize is measured in points](https://www.mathworks.com/help/matlab/ref/plot.html). Do not pass `0.20` directly as the size argument or `SizeData` of [scatter, which specifies marker area in points squared](https://www.mathworks.com/help/matlab/ref/scatter.html); it is a different size parameter.

## 3. Text-Aware Layout

- Calculate the canvas, margins, and any interplot gap using the selected placement and the actual final-font extents. Run `drawnow` before measuring; `TightInset` can help measure axes text, but separately account for legends, annotations, and other visible objects that extend beyond it. Record the chosen padding in the task configuration and remeasure after moving objects or changing text.
- Derive explicit canvas dimensions rather than accepting automatic export cropping. Do not turn a reference image's approximate overall width into a fixed canvas. Keep the configured internal plot boxes and main font size when more text space is needed, subject to the placement's resizing permissions and any explicitly fixed canvas.
- Check the complete canvas against a known available document or column width. A compact internal box is not a guarantee that arbitrary labels fit every column. If required text and padding exceed the available width, report the required and available dimensions and obtain revised requirements; do not silently scale the figure, shrink its box or text, clip labels, or claim that it fits. Do not require a journal width when none is known; deliver and report the measured native width.

## 4. Export and Native-Size Placement

- Deliver the reproducible MATLAB script, a single-page vector PDF, and a PNG rendered from that same accepted PDF at `600 dpi` or higher. An editable FIG is optional only when requested; it is not a default deliverable for this workflow.
- Preserve the full configured canvas, margins, and white background. On R2025a or later, `exportgraphics` may be used with `ContentType = 'vector'`, `Units = 'centimeters'`, `Width = canvas_mm(1) / 10`, `Height = canvas_mm(2) / 10`, and `Padding = 'figure'`. Convert the configured millimeters to a supported export unit; do not pass `Units = 'millimeters'` to `exportgraphics`. For R2020a–R2024b, use full-canvas `print` with `-dpdf` and `-painters`, `PaperUnits = 'centimeters'`, `PaperSize = canvas_mm / 10`, `PaperPosition = [0, 0, canvas_mm / 10]`, and `PaperPositionMode = 'manual'`. The `print` backend may also be used on newer releases. MATLAB R2020a or later is a compatibility target, not a claim that every release was tested.
- Use the final PDF as the acceptance source. Check its page dimensions with `pdfinfo`, measure internal frame centerlines separately from stroke thickness, and render the PNG with `pdftoppm` at a minimum of `600 dpi`. Verify that curves and markers remain vector objects rather than assuming that the PDF extension proves it. Correct layout or export rounding if it exceeds the main workflow's `0.1 mm` dimension tolerance.
- The required frame dimensions and font size apply at the PDF's native physical size. In LaTeX, include the PDF without a resizing option when it already fits:

  ```latex
  \begin{figure}[!t]
  \centering
  \includegraphics{figures/independent_plot.pdf}
  \caption{A task-specific description.}
  \end{figure}
  ```

  Use `figure*` for a two-column spanning figure. Packages such as `graphicx` must be loaded in the manuscript. Do not stretch a smaller figure to `\columnwidth` or `\textwidth`, or shrink an oversized one to fit, while claiming that the original frame dimensions and `8 pt` text are preserved. If resizing is explicitly requested, report its scale factor and resulting physical dimensions and font sizes.

## 5. Acceptance Checks

- Check source-to-series mappings, paired sample counts and ordering, gaps, ranges, units, colors, and any requested annotations against the confirmed configuration.
- For the high-density bifurcation scatter scenario, check the no-line, filled-circle, no-edge combination and the actual marker size, or record explicit user overrides. Verify that every supplied sample and its parameter pairing are retained, including repeated coordinates. Inspect both the complete figure and locally dense regions in the final PDF and its high-resolution rendering; record the final point size and any adjustment based on frame size, overlap, and visibility rather than total point count alone. Continue to verify vector content and use the same accepted PDF for the high-resolution preview.
- Check the single or side-by-side arrangement and each plot's internal frame dimensions against the selected placement. For a pair, confirm equal frame sizes, aligned top and bottom edges, left-to-right order, complete axis text on each plot, and independently configured ranges.
- Check the actual PDF fonts, main text size, subscript appearance, page size, and vector content. Inspect the PDF-derived high-resolution preview for clipping, text collisions, annotation overlap, and unnecessary whitespace. Verify any known document-width limit without altering the accepted frame or font size.
- Report the MATLAB release, export backend, native canvas dimensions, frame measurements, any user overrides, and checks actually performed. Keep synthetic verification inputs and outputs outside the installed skill and label them as synthetic layout examples, not scientific evidence.
