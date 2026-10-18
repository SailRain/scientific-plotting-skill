# Pure Time-Series Plot Workflow

Read this file only when creating pure time-series plots of signals over time; also apply the [Scientific Plotting Workflow](../../SKILL.md) and the selected placement file.

## 1. Data and Arrangement

- Inspect the user-specified data files directly to identify the delimiter, headers, time column, and signal columns; configure column mappings from the actual headers or confirmed column order, without assuming a fixed number of columns or fixed column names.
- Check that the target columns contain finite numeric values, time is strictly increasing, and data are available in the required window; at least two valid samples are required when connecting points with lines. The data must cover any specified finite time interval; do not count portions without data as covered.
- Preserve the user-specified or confirmed mapping for file order and panel labels; do not automatically reorder files by filename. The selected placement determines the specific row and column arrangement.

## 2. Data Windows and Ranges

- When extracting a time series, one adjacent original sample may be retained on each side of the window to preserve line segments at the boundaries; the time axis must still be strictly limited to the specified window.
- User-specified axis ranges take precedence. If a specified range clips the selected data and the user has not explicitly requested a local view, report the clipping and do not claim that the data are displayed in full.
- When no range is specified, add approximately `3%` of the span at each end, based on the actual extrema within the window. If adjacent samples outside the window are retained, also check whether the visible line segments at the boundaries extend beyond the range and adjust the range based on the visible portions within the window when necessary; do not include invisible peaks outside the window in the range.
- Determine the y-axis range independently for each waveform; do not impose a common range on all y-axes simply because multiple groups are arranged together. Use a small range appropriate to the magnitude for a constant signal; for a constant zero signal, choose a readable range based on the units and context.
- Use readable tick values, but do not expand the range or create large empty areas merely to obtain round numbers.

## 3. Lines, Axes, and Labels

- Use a white axes background with black plot boxes, ticks, and text; default to a four-sided box with the grid off, and do not add titles or legends. Set the box line width to `0.35 pt`, direct ticks inward, and use `TickLength = [0.008, 0.008]`.
- Use `PositionConstraint = 'innerposition'`; plot box dimensions in the placement refer to the internal plot box, excluding ticks and labels.
- The default waveform line width is `0.75 pt`; use the user's setting when explicitly specified.
- Use colors specified by the user or confirmed in the current conversation. If the user specifies only one curve color, apply it to all curves in the task; if there is no basis for choosing a color, ask rather than infer it from the signal type or treat colors from past examples as defaults.
- Use the required window for the time axis, with simple, evenly spaced ticks that are not crowded. Use `t, s` and `v_C, V` only when the time unit is confirmed to be seconds and the signal is confirmed to be a capacitor voltage in volts; configure other variables or units for the task.

### X-Axis Text Modes

- `each-panel`: Show x-axis tick labels and the xlabel on every panel. This is the default for a single plot; also use it when multiple plots have different time ranges or ticks, when the user requires each plot to be readable independently, or when the user explicitly requests labels on every panel.
- `shared-bottom`: Retain x-axis tick marks on panels above the bottom row, but hide their x-axis tick labels and xlabel; show complete x-axis text only on the bottom row, or only on the bottom panel in a single vertical column. This compact mode is the default for multiple vertically stacked plots with the same time range and ticks.
- `hidden`: Retain x-axis tick marks on every panel, but hide all x-axis tick labels and xlabel text. Use this mode only when a larger composite figure already provides a common x-axis or when the user explicitly requests that the text be hidden; it must not be the default for a standalone figure.
- When the user has not specified a mode, select `each-panel` for a single plot, `shared-bottom` for multiple plots with the same time range and ticks, and `each-panel` for multiple plots with different time ranges or ticks. If sharing cannot be confirmed, verify the data and configuration first; do not guess from the appearance of a screenshot.

## 4. Single and Split Y-Axes

- `single-y`: Show only the left y-axis. This is the default mode. The presence of multiple curves alone does not trigger a right axis; retain a single y-axis unless the user explicitly requests that multiple variables be split across axes.
- `split-y`: Enable this mode only when the user explicitly requests that multiple variables be split across axes, typically for curves with different variables, units, or ranges. Before enabling it, confirm whether each curve belongs to the left or right axis, along with the variable names, units, ranges, and ticks on both sides.
- The left and right y-axes may have independent `YLim` and `YTick` settings. Do not force identical ranges or ticks on both sides to imitate an example, and do not silently normalize, convert, or scale the data; any conversion requires a user request or a confirmed basis.
- When using `split-y`, display right-side tick labels and a y-label on each panel that match its curve-to-axis mapping; right-axis text sits outside the internal plot box and must not change the internal plot box dimensions specified by the placement. Add only the necessary outer margin on the right. When using `single-y`, do not display right-axis ticks, labels, or placeholder text.

## 5. Panel Labels

- Preserve the panel-label text mapping specified by the user or confirmed in the current conversation; do not generate labels automatically from filenames or adopt the automatic `(a)`, `(b)` rules for MAT slices. If the task requires panel labels but their mapping cannot be verified, confirm it first.
- By default, place panel labels inside the lower-right corner of the plot box at approximately `(0.985, 0.055)` in normalized coordinates, right-aligned and bottom-aligned. If a label obscures a curve, first try the upper-right corner at `(0.985, 0.955)` with top alignment, then fine-tune its position based on the actual empty area.
- Panel labels must not be clipped. Do not add background fills or borders, and do not expand axis ranges to accommodate labels.

## 6. Export and Plot-Specific Acceptance Checks

- Use a white figure background and the `painters` renderer to export a single-page vector PDF through `exportgraphics` with `ContentType = 'vector'` and a white background. Preserve the full canvas and margins specified by the placement so that automatic tight cropping does not alter the layout.
- The final PDF is the basis for layout acceptance. Use `pdfinfo` to check the page against the configured dimensions; render a PNG from that PDF at a minimum of `600 dpi` through `pdftoppm`. The delivered preview must also come from the same PDF. Verify that the PDF actually retains vector curves rather than judging by its extension alone.
- Verify the time window, number of original samples, and adjacent boundary samples to confirm that data outside the window have not been mistakenly counted within the displayed range.
- Check that the independent y-axis of each plot fully covers the visible data and that a common range has not created unnecessary empty space.
- Check that the actual `each-panel`, `shared-bottom`, or `hidden` x-axis text mode and the conditions for selecting it match the configuration.
- Check that the `single-y` or `split-y` mode, curve-to-axis mapping, and ranges and ticks on both sides match the confirmed configuration; do not automatically create a right axis because multiple curves are present.
- Check that waveform line widths, colors, time labels, variables, units, and panel labels match the configuration.
- In the final PDF and its high-resolution rendering from the same source, confirm that plot boxes, ticks, subscripts, and panel labels are clear, with no clipping, overlap, or curves obscured by other elements.
