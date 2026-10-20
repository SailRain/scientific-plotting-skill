# Shared Scientific Typography

Apply these rules to every plot type and placement, together with the [main workflow](../SKILL.md). They also apply to new plot types added later. Typography does not select a plot type, alter a placement's dimensions, or change its required delivery formats.

## Mathematical Minus Signs

- Use the literal mathematical minus sign `−` (`U+2212`, MATLAB `char(8722)`) for displayed unary negatives and subtraction. Cover all visible coordinate ticks, right-side axes, colorbar text, unit and scientific-notation exponents, formulas, parameter text, legends, titles, and annotations. Examples are `−1000`, `s^{−1}`, `10^{−3}`, `x−y`, and `a = −0.5`.
- ASCII `-` (`U+002D`) and en dash `–` (`U+2013`) are not the default mathematical minus glyph. Preserve their legitimate uses in English words, identifiers, filenames, and range punctuation, such as `time-response`, `Run-1`, `data-1.csv`, and `1–3`.
- Change display strings only. Keep original numeric arrays, sample order and pairing, category codes, coordinate positions, limits, ticks, and source metadata unchanged. Executable MATLAB expressions such as `y = x - 1` and `10^-3` retain their normal operators.
- Identify mathematical content from verified task semantics. Construct its display strings explicitly; do not run a blanket replacement across source files, every graphics object, or arbitrary caller-provided text. For mixed prose and mathematics, normalize only the mathematical fragments and preserve the surrounding prose.

## Fixed Subscript Baseline Correction

- Raise each declared mathematical subscript by exactly `1 pt` from the same expression's native placement. This is a physical displacement at native export size, approximately `0.35278 mm`; do not scale it with figure width, font size, or screen zoom. Preserve the main text, units, superscripts, and all selected font sizes, styles, and colors. A superscript-only label can retain native text rendering.
- For rotated labels, the displacement follows the label's local upward direction, not the page's vertical direction. Keep the native whole-label alignment and main-text anchor; do not recenter a newly shortened bounding box in a way that moves the other glyphs.
- Use the [measured text compositor](../scripts/draw_scientific_text.m) for declared mathematical text. It constructs a native reference, measures SVG positions with all ancestor transforms, and creates editable MATLAB `Text` parts. When MATLAB outlines the SVG text, it can register each original-glyph path against a standalone original-glyph reference at the measured font, size, and style. Complete path geometry must match up to translation; a bounding-box guess is insufficient. It does not parse arbitrary TeX strings, scan every graphics object, or turn underscores in filenames and ordinary text into subscripts.
- Do not hardcode a native subscript drop or script-size ratio from one example. Calibration must correspond to the actual expression, font, sizes, rotation, alignment, physical geometry, and installed release. Temporary references belong outside the installed skill. MATLAB's JVM and supported native SVG output are required. Unsupported serialization, unmatched outlines, or ambiguous run mappings must be reported rather than approximated; inherited font attributes on outlined paths are not reliable font evidence.
- Rebuild the text after changing its content, font, geometry, rotation, or alignment. Each rebuild starts from the unmodified native reference and applies the correction once. Replace or delete the previous owned group; do not add another point to already corrected positions.
- If the fixed correction causes a collision, first use the selected placement's permitted surrounding space or annotation arrangement. Do not silently change the correction or font size. Unsupported nested structures require explicit task adaptation and final verification; retaining an uncorrected subscript does not satisfy this rule.

### Compositor Interface

```matlab
[group, metrics] = draw_scientific_text(ax, anchor_pt, atoms, options);
```

`anchor_pt` is a two-element position in points relative to the parent axes. `atoms` is a struct array describing literal mathematical fragments; attachments belong to their own atom rather than being inferred from punctuation:

| Atom fields | Meaning |
| --- | --- |
| `text` | Required literal main text; use Unicode characters for Greek letters and mathematical signs |
| `subscript`, `superscript` | Optional literal, single-level script text; multiple characters and simultaneous scripts are supported |
| `font_angle`, `subscript_angle`, `superscript_angle` | Part-specific `normal` or `italic` style, configured from the confirmed mathematical meaning |
| `text_size_pt`, `subscript_size_pt`, `superscript_size_pt` | Optional explicit part sizes; omitted script sizes retain the measured native behavior |

Declare italic styling for each variable, including variable subscripts such as the `C` in `v_C`. Keep units, descriptive subscripts, and numeric indices upright. Omitted angle fields default to `normal`; the compositor does not infer scientific meaning from the literal characters. Apply these style checks to synthetic verification figures as well as delivered research figures.

Options include `font_name` (Times New Roman), `font_size_pt` (`8`), `color`, `rotation`, `horizontal_alignment`, `vertical_alignment`, `subscript_raise_pt` (`1`), and an optional `tag`. Preserve explicit task typography. Use another correction only when explicitly requested; `0` can be used for a verification control. The returned group contains editable native text objects. `metrics.extent_pt` describes its complete rendered bounds in the parent axes' point coordinates; native-layout and run metadata support verification and placement calculations. For outlined SVG output, a safe-payload probe supplies font metadata only; the original glyphs supply all position measurements and must pass complete outline matching.

For example, after finalizing the axes geometry:

```matlab
atom = struct('text', 'v', 'subscript', 'C', ...
    'font_angle', 'italic', 'subscript_angle', 'italic');
text_options = struct('horizontal_alignment', 'center', ...
    'vertical_alignment', 'baseline', 'tag', 'voltage_label');
[label_group, label_metrics] = draw_scientific_text( ...
    ax, [40, 20], atom, text_options);
```

Keep ordinary text such as `Run-1` or `file_name` literal. Create separate atoms for units and surrounding prose when necessary, attaching separator spaces to a visible atom rather than creating a whitespace-only atom with no measurable glyph. Preserve original labels and source metadata separately from the declared display layout. Clear only the corresponding native visible label after its replacement succeeds, and measure the complete replacement before accepting the canvas.

### Workflow Integration

- All four task-script PDF workflows use the compositor for mathematical labels, formulas, annotations, and legend text containing subscripts. Preserve hidden-axis text modes and shared-axis conditions; do not introduce a visible label where the workflow suppresses one.
- A native legend does not expose a supported per-subscript baseline setting. For affected entries, construct editable line/marker samples and composed text, retaining the source series identities, ordering, colors, line styles, marker styles, token dimensions, and configured arrangement. Exclude these display objects from data-series counts and automatic legends.
- Slice adapters use optional `options.text_layouts` to declare structured x/y labels, panel labels, slice titles, and category labels. Unspecified entries retain the existing string behavior. The adapter must provide layouts for mathematical subscripts requiring this correction; the renderer does not infer their meaning from arbitrary strings.
- For structured category labels, hide only their corresponding native colorbar text and draw the replacement at the same category centers. Keep original display aliases and category codes in metadata, preserve the category/color mapping, and use actual composed bounds in space checks. See the [slice interface](plot-types/mat-bifurcation-slices.md) for configuration fields.
- Reopening the FIG must retain editable text parts and their declared semantic roles. The helper and display configuration do not modify numerical data, axis limits, tick positions, classification cells, or placement presets.

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
- Minus formatting alone requires no additional renderer option or numerical data interface. Structured subscript labels use the optional display configuration described above. Reopening the editable FIG must retain the prepared glyphs, labels, and numeric provenance.

## Acceptance

- Check the actual exported characters and fonts, not only the MATLAB source. In a vector PDF, confirm that known mathematical negative signs extract as U+2212 and use embedded Times New Roman without a fallback font. Main text remains at its configured size, 8 pt by default; superscripts and subscripts may be smaller.
- Compare corrected text with an untouched native reference at the same settings. Each subscript must move `1.00 pt` along the local upward direction, within `0.05 pt`; main-text, unit, and superscript positions must remain within `0.05 pt` of the reference, with identical sizes and styles. Check horizontal, vertical, tilted, and combined-script examples. SVG calibration alone does not establish acceptance of a PDF or PNG backend.
- Inspect the final high-resolution rendering for missing glyphs, wrong baseline placement, clipping, and overlap, including negative ticks, negative powers, right-side axes, formulas, legends, annotations, and colorbar labels. Follow the plot type's existing vector PDF/derived PNG or editable FIG/native PNG checks.
- Verify that source values, pairings, limits, tick positions, display factors, hidden-label modes, and nonmathematical hyphens remain intact. Record the MATLAB release and export backends actually tested; compatibility targets do not certify releases not run.
