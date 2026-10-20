# Shared Scientific Typography

Apply these rules to every plot type and placement, together with the [main workflow](../SKILL.md). They also apply to new plot types added later. Typography does not select a plot type, alter a placement's dimensions, or change its required delivery formats.

## Mathematical Minus Signs

- Use the literal mathematical minus sign `−` (`U+2212`, MATLAB `char(8722)`) for displayed unary negatives and subtraction. Cover all visible coordinate ticks, right-side axes, colorbar text, unit and scientific-notation exponents, formulas, parameter text, legends, titles, and annotations. Examples are `−1000`, `s^{−1}`, `10^{−3}`, `x−y`, and `a = −0.5`.
- ASCII `-` (`U+002D`) and en dash `–` (`U+2013`) are not the default mathematical minus glyph. Preserve their legitimate uses in English words, identifiers, filenames, and range punctuation, such as `time-response`, `Run-1`, `data-1.csv`, and `1–3`.
- Change display strings only. Keep original numeric arrays, sample order and pairing, category codes, coordinate positions, limits, ticks, and source metadata unchanged. Executable MATLAB expressions such as `y = x - 1` and `10^-3` retain their normal operators.
- Identify mathematical content from verified task semantics. Construct its display strings explicitly; do not run a blanket replacement across source files, every graphics object, or arbitrary caller-provided text. For mixed prose and mathematics, normalize only the mathematical fragments and preserve the surrounding prose.

## Task-Specific MATLAB Scripts

1. Finalize axis limits, scales, tick positions, and any chosen display factors before constructing visible labels. Format the existing numerical tick values, then replace minus characters only in those known numeric strings. Treat each visible ruler separately, including both rulers of `yyaxis`, any numeric colorbar, and logarithmic tick exponents. A traversal of ordinary `Text` objects alone does not cover these labels.
2. Preserve the selected numerical precision, factor, and tick positions. For a selected scientific multiplier, divide only the displayed tick numbers by that factor and show the factor exactly once. Its negative exponent must also contain U+2212. If MATLAB's automatic multiplier cannot meet the glyph rule, suppress that automatic text and explicitly render the same selected factor in the configured location. Never silently drop a factor or rescale the source samples.
3. Preserve each workflow's hidden and shared-axis text modes. Do not populate a hidden upper axis with labels while normalizing its ticks. Rebuild affected labels and multiplier text after changing limits, ticks, scales, or display factors; manually assigned labels otherwise become stale.
4. Use literal U+2212 in verified mathematical text with the existing `none` or `tex` interpreter. Keep TeX superscript and subscript structure, for example `s^{−1}`. Do not switch all text to the LaTeX interpreter or change fonts to obtain a minus glyph.
5. Apply the final typography after plotting commands that may reset axes properties. Run `drawnow`, then measure the actual strings in their final font before deriving margins and gaps. The mathematical minus can be wider than an ASCII hyphen; preserve configured frames and font sizes while resolving any crowding under the selected placement's rules.

For example, the following is display formatting for an explicitly unscaled linear y-axis. The arithmetic operators and numeric coordinates are unchanged:

```matlab
minus_sign = char(8722);
tick_values = ax.YTick;
ax.YAxis.Exponent = 0; % This example explicitly uses no display multiplier.
ax.YTickLabel = strrep(compose('%g', tick_values), '-', minus_sign);
ylabel(ax, ['Rate, s^{' minus_sign '1}'], 'Interpreter', 'tex');
text(ax, 0.05, 0.9, ['Offset = ' minus_sign '0.5'], ...
    'Units', 'normalized', 'Interpreter', 'none');
```

Use the common Times New Roman and 8 pt defaults for the axis and text objects, or their explicit user overrides. This example is not a global axes formatter; adapt it to the confirmed precision, scaling, and visibility of each ruler.

## Categorical Slice Renderer and Adapters

- The [slice renderer](../scripts/render_bifurcation_slices.m) formats its own manual x/y numeric ticks with `%g` and replaces ASCII minus signs in those generated strings with U+2212. This also covers the negative exponent in a `%g` result such as `1e−06`. The numeric inputs and category mapping are unchanged.
- Axis labels, slice titles, panel labels, and category labels can contain arbitrary text. The renderer preserves those caller-provided strings. Prepare their mathematical fragments in the task adapter using U+2212, including numeric code aliases when their meaning has been confirmed. Do not guess whether an unmarked string such as `x-y` is a formula or a name.
- Keep source names and metadata separate from display aliases. For example, a source title can remain `Run-1`, while a verified parameter annotation uses `a = −1`. The colorbar must display the prepared aliases; its separate label objects are part of typography acceptance.
- No additional renderer option or data interface is required. Reopening the editable FIG must retain the prepared glyphs, labels, and numeric provenance.

## Acceptance

- Check the actual exported characters and fonts, not only the MATLAB source. In a vector PDF, confirm that known mathematical negative signs extract as U+2212 and use embedded Times New Roman without a fallback font. Main text remains at its configured size, 8 pt by default; superscripts and subscripts may be smaller.
- Inspect the final high-resolution rendering for missing glyphs, wrong baseline placement, clipping, and overlap, including negative ticks, negative powers, right-side axes, formulas, legends, annotations, and colorbar labels. Follow the plot type's existing vector PDF/derived PNG or editable FIG/native PNG checks.
- Verify that source values, pairings, limits, tick positions, display factors, hidden-label modes, and nonmathematical hyphens remain intact. Record the MATLAB release and export backends actually tested; compatibility targets do not certify releases not run.
