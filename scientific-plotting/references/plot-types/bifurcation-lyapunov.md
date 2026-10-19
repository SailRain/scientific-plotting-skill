# One-Dimensional Bifurcation and Lyapunov Exponent Comparison

Read this file when a comparison group contains a one-dimensional bifurcation plot above a Lyapunov exponent plot. This is a separate plot type from an Independent 2D bifurcation scatter plot without an exponent panel. Also apply the [main workflow](../../SKILL.md) and the selected placement file; physical box dimensions, group arrangements, and geometry overrides belong to that placement.

## 1. Existing Data and Group Configuration

- Plot existing bifurcation samples and existing exponent data only. Do not generate simulations, calculate exponents, reclassify samples, or infer dynamical mechanisms.
- Configure each group's parameter fields, retained state samples, exponent fields and identities, units, parameter transformations, axis scales, source files, and order from the actual data and verified metadata. A group may use several source files; file count does not determine group count.
- Verify sample lengths, matrix orientation, and parameter-to-state pairing before adapting input arrays. Retain every original sample, including repeated coordinates, without interpolation, smoothing, downsampling, deduplication, or sorting. Distinct parameter grids for the two panels are allowed: plot each series against its own original parameter coordinates, without pairing records by row or resampling them onto a common grid.
- By default, draw all confirmed exponent series in their confirmed identity order. Honor an explicitly requested subset. Do not select only the largest exponent, reorder exponents by their instantaneous values, or infer labels such as `LLE` or `LE_2` from a screenshot. Preserve source-defined gaps and separate runs rather than connecting across them.
- Report missing, NaN, and infinite coordinates or exponent values, including `-Inf`, and the resulting display limitations. Preserve the source records and mappings; do not silently replace values with zero, cap them at finite numbers, or discard them. Resolve any necessary display treatment with the user, and do not claim complete display of values that cannot be represented on finite axes.

## 2. Shared or Independent Horizontal Axes

- Verify that the two panels use the same physical parameter, units, transformation, and axis scale before sharing x. When these conditions hold and separate axes have not been requested, use identical `XLim`, `XTick`, and scale in both panels. `linkaxes(..., 'x')` may maintain this relationship within a group.
- In shared-x mode, show the x-axis tick numbers, variable, and units only below the exponent panel. Retain the upper panel's frame and tick marks. Both panels keep their own complete y-axis text and independently configured y-ranges.
- Explicit user ranges take precedence; report unrequested clipping. With no explicit x-range, cover the union of the two panels' actual parameter coverage and use modest padding, approximately 3% for linear axes. Use scale-appropriate padding for a logarithmic parameter. Do not invent samples to fill unequal coverage, and disclose any coverage difference relevant to the comparison.
- If parameter meaning, units, transformation, or scale differ or cannot be verified, explain why x is not shared and retain complete horizontal-axis text on both panels. Do not link axes, hide the upper labels, convert units, or normalize coordinates automatically.
- Side-by-side groups remain independent. Share x only within each eligible group; geometric alignment across groups does not imply identical ranges or ticks.

## 3. Bifurcation Samples, Exponent Curves, and Colors

Use the following starting combination for the upper panel, with verified paired coordinate vectors and a color resolved through the shared rules:

```matlab
plot(axBifurcation, parameterValues, retainedSamples, ...
    'LineStyle', 'none', ...
    'Marker', 'o', ...
    'MarkerSize', 0.20, ...
    'MarkerFaceColor', seriesColor, ...
    'MarkerEdgeColor', 'none');
```

- `MarkerSize` here is in points. Retain all samples and do not restrict `MarkerIndices`. Start at `0.20 pt` and adjust to the actual upper box, local overlap density, and visibility in the final native-size rendering, recording any adjustment. Do not determine point size mechanically from total point count. User-specified styles take precedence.
- Draw exponent series as solid lines without markers, with a default line width of `0.6 pt`. Preserve each curve's parameter pairing and supplied connection order; honor explicit user styles.
- Label the exponent y-axis `LLE` when the largest exponent has been confirmed and is the only exponent drawn; use `LEs` when drawing multiple exponent curves. For a single series not verified to be the largest, use its confirmed identity or the neutral label `LE`, not an inferred `LLE`. Explicit user labels take precedence; keep confirmed units consistent with the source data.
- When the user has not specified numerical scaling, decide whether a display multiplier improves tick readability based on the actual values, tick labels, and available space. Append any chosen multiplier to the axis name, for example `LEs, ×10^3` or `LLE, ×10^3`, with the exponent typeset as a superscript. Use the Times New Roman multiplication glyph `×` (`U+00D7`) and verify the exported font; MATLAB's TeX `\times` can use a Symbol font instead. Tick labels then show the original tick values divided by `10^n`; the displayed numbers multiplied by the labeled `10^n` recover the source values. Omit an unnecessary multiplier and do not assume `10^3` for every dataset. Honor an explicit user scale instead of choosing one automatically. Keep the original exponent samples, axis-coordinate positions, zero reference, and data-based ranges unchanged, and suppress any duplicate scientific multiplier elsewhere on the axis. Record the chosen display factor in the task configuration.
- Follow the [shared color rules](../color-schemes.md). Reuse `waveform_colors` as the ordered series palette without assigning time-domain meaning. Configure bifurcation series first, followed by exponent identities in their confirmed order; retain the same identity-to-color mapping across groups and resolve extra distinct colors through the shared rules. Explicit user colors take precedence. The zero reference is separate from this palette.
- Use a white background, black axes and text, a four-sided box, inward ticks, `TickLength = [0.008, 0.008]`, and a default box line width of `0.35 pt`. Turn both major and minor grids off unless the user requests them.
- Apply Times New Roman and the common `8 pt` main-text default to ticks, variables, units, and any annotations. Use point font units and label/title font-size multipliers of `1`; subscripts may be smaller as needed. Variables are italic; units and descriptive subscripts are upright. Add legends, titles, group labels, arrows, or other annotations only from the user's instructions or confirmed task configuration, not by copying the reference image.

## 4. Exponent Zero Reference and Vertical Ranges

- Show a black short-dashed horizontal reference at zero, default line width `0.35 pt`, behind the exponent data curves. Start with approximately `0.8 mm` dash segments and `0.5 mm` gaps at native export size, honoring explicit user styles. If MATLAB's native dashed style produces overly long dashes, draw reproducible vector dash segments from the actual box width and current horizontal limits/scale rather than reducing the line width to change the pattern. Recalculate those segments after changing ranges or geometry. Draw the reference independently of the grid and exclude it from legends and exponent-series counts; it does not consume a palette entry or constitute an additional measured series.
- With automatic exponent y-limits, cover all finite displayed exponent values and zero, then add modest padding, approximately 3% of a nonzero span. Use a readable range containing zero for constant data. Include an explicit zero tick. The default exponent y-scale is linear so that zero can be shown.
- If the user specifies y-limits or a scale that cannot display zero, report the conflict with the zero-reference requirement and obtain revised requirements rather than silently hiding the reference, altering data, or expanding an explicitly fixed range.
- Configure the bifurcation y-range independently from its retained samples and user limits. Do not copy the exponent range, screenshot tick values, or voltage labels. Report unrequested clipping and use modest data-based padding when limits are unspecified.

## 5. Layout, Export, and Native Size

- Use `PositionConstraint = 'innerposition'` and physical units. Keep automatic aspect ratios unless explicitly requested otherwise, and do not let an aspect-ratio constraint silently change a configured box. Align each group's upper and lower left and right frame borders according to the placement.
- Run `drawnow` before measuring final-font text extents. Use axes `TightInset` together with the measured extents of any other visible objects to derive margins, the vertical panel gap, and any intergroup gap, with explicitly recorded safety padding. Reserve upper x-axis text space in nonshared mode. Recalculate after moving objects; do not infer gaps or a fixed total canvas from screenshots.
- Preserve configured boxes and typography while adding necessary surrounding space, subject to explicit canvas constraints. Check the complete native canvas against any known available column or document width, and report required versus available width when it cannot fit. Do not shrink boxes or text, clip labels, or silently resize the figure to meet a width limit. If no width limit is known, report the measured native canvas rather than guaranteeing a fit.
- Deliver a reproducible task-specific MATLAB script, a single-page vector PDF, and a PNG rendered from that same accepted PDF at `600 dpi` or higher. No separate general renderer is bundled. Preserve the full canvas, white background, and margins rather than using automatic tight cropping.
- On R2025a or later, vector `exportgraphics` may use `ContentType = 'vector'`, `Units = 'centimeters'`, `Width = canvas_mm(1) / 10`, `Height = canvas_mm(2) / 10`, and `Padding = 'figure'`. For R2020a–R2024b, use full-canvas `print` with `-dpdf`, `-painters`, `PaperUnits = 'centimeters'`, `PaperSize = canvas_mm / 10`, `PaperPosition = [0, 0, canvas_mm / 10]`, and `PaperPositionMode = 'manual'`. The `print` path is also available on newer releases; the compatibility target does not certify releases not actually run.
- Check PDF page dimensions and frame centerlines separately. Correct export or coordinate rounding that exceeds the main workflow's `0.1 mm` tolerance, preserving the requested final targets. Render the accepted PDF using `pdftoppm` at a minimum of `600 dpi`, and verify that markers, curves, and the zero reference remain vector content.
- Box dimensions and the `8 pt` default refer to native PDF size. In LaTeX, use `\includegraphics{...}` without resizing after confirming the total width fits; use `figure*` for a two-column spanning figure. A requested rescaling changes the frame dimensions and font size and must be reported.

## 6. Acceptance Checks

- Verify each source-to-series mapping, parameter/state pairing, sample count including duplicates, exponent identity and order, and original coordinate grids. Confirm no implicit resampling, thinning, reordering, or replacement of nonfinite values.
- Confirm each group's upper/lower structure and configured inner dimensions, paired left/right border alignment, and all corresponding borders across a requested side-by-side arrangement. Check that neighboring groups retain independent ranges.
- Verify the shared-x conditions, matching limits/ticks/scales and bottom-only x text when eligible; otherwise check complete independent x text and no incorrect linking.
- Check marker/line properties, shared palette assignments, and user overrides. Verify the `LLE`/`LEs` labeling against the confirmed exponent identities and selected curves, any display multiplier against the actual tick labels and unchanged source values, and the absence of a duplicate multiplier. Confirm the short-dashed black zero reference and its native-size dash/gap appearance, visible zero tick and y-range coverage, disabled major/minor grids, and reference exclusion from legends and measured-series counts.
- Check the final PDF's native page and frame dimensions, actual Times New Roman main text at the configured size (`8 pt` by default), readable subscripts, and vector content. Inspect its high-resolution rendering at full-figure and local detail levels for overlapping tick labels between panels, clipping, data obscured by annotations, and unnecessary whitespace.
- Report the MATLAB release, export backend, measured canvas and boxes, sample mappings, user overrides, and checks actually completed. Synthetic verification coordinates demonstrate layout only and are not simulations or evidence of dynamical behavior; keep all such artifacts outside the installed skill.
