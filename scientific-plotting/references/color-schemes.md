# Shared Color Schemes

Color schemes provide reusable color choices across plot types and placements. They do not add a third routing dimension or change fonts, line widths, plot-box dimensions, colorbar placement, axis styles, time windows, or export requirements. Continue to apply the [main workflow](../SKILL.md), selected plot-type reference, and selected placement.

## 1. Available Schemes and Precedence

| ID | Display name and author | Status | Definition |
| --- | --- | --- | --- |
| `sailrain` | SailRain | Default; currently the only bundled scheme | [SailRain color data](../assets/color-schemes/sailrain.json) |

- Explicit user colors and a confirmed task configuration take precedence over scheme defaults. Preserve a verified dataset color mapping when it is part of that confirmed configuration. If the user specifies only one curve color, apply it to all curves in the task, including both views of a phase/waveform composite.
- Otherwise, use the user's selected scheme; when no scheme is specified, use SailRain. An unknown scheme is an error, not a reason to fall back silently to SailRain.
- Do not infer category meanings, physical variables, or units from a palette, its source labels, or a reference image. Scheme selection changes colors only. Reference images supplied for the SailRain scheme establish curve colors; their colored annotations or axis labels do not override the existing black axes, ticks, and text rules.
- Record the scheme ID, selected palette rows where applicable, and the actual identity-to-RGB mapping in the reproducible task configuration. Record explicit color overrides there as well.

## 2. SailRain Defaults

The [JSON definition](../assets/color-schemes/sailrain.json) is the single production source for RGB values. Load it rather than copying RGB tables into scripts or examples.

### Categorical Plots

SailRain supplies the complete ordered 13-color palette originating in SailRain's two-dimensional bifurcation plots. `categorical_source_labels` records RS, P1–P9, MP, CH, and UB as provenance only. These labels are not a category lookup table and must not be matched automatically to new data.

Confirm category definitions and display order independently. Choose a distinguishable subset from the full palette; do not require the first N rows. Map the selected rows to the confirmed display order and record both row indices and resulting RGB values. Reordering categories requires moving codes, labels, and colors together. Palette selection must not reorder categories or change their meanings.

The slice demo explicitly selects rows `[1, 2, 12]` to retain its gray, bright cyan, and magenta example colors. This subset is not a default for every three-category dataset.

### Waveforms

The waveform palette has three rows in red, blue, then black priority. Assign the first required curve identity red, the next distinct identity blue, and the next black, using the task's confirmed curve order. Configure identities explicitly and retain their colors across panels, including panels where only some identities appear. Do not restart the palette for each panel or bind a color to a fixed physical variable name.

This rule applies to both pure time series and the waveform side of phase/waveform composites. Independent 2D coordinate plots also reuse `waveform_colors` as their default ordered series palette, without implying that their coordinates represent time-domain waveforms. An explicit single-color request still applies to all curves as described above.

### Phase Trajectories

Use `phase_trajectory_color` for phase trajectories unless overridden. SailRain defines this separately from the categorical palette's bright cyan; do not replace it with MATLAB's shorthand cyan color. Multiple trajectories may use this same default color when distinct colors are not required.

### Additional Distinct Colors

When the task requires more mutually distinct colors than the applicable palette supplies—13 categorical colors, three waveform colors, or one phase-trajectory color—confirm extra explicit colors or another scheme with sufficient colors before rendering. Do not invent, interpolate, or cycle colors to fill the gap. Deliberate color reuse under an explicit user instruction is allowed and must be recorded.

## 3. MATLAB Loader and Task Configuration

Add this skill's `scripts` directory to the MATLAB path, then call the [loader](../scripts/load_color_scheme.m):

```matlab
scheme = load_color_scheme();
% Equivalent explicit selection:
scheme = load_color_scheme('sailrain');

palette_indices = [1, 2, 12];
categories.colors = scheme.categorical_colors(palette_indices, :);
waveform_color = scheme.waveform_colors(1, :);
phase_color = scheme.phase_trajectory_color;
```

The example palette indices are the synthetic demo's selection, not a semantic rule. Configure the actual category and curve identities before assigning colors. The slice renderer's interface remains unchanged: pass `categories.colors` explicitly to `render_bifurcation_slices`; the renderer does not load schemes itself.

The loader returns a scalar struct with these fields:

| Field | Contents |
| --- | --- |
| `id` | Scheme ID matching the definition filename |
| `display_name`, `author`, `source_note` | Display name, attribution, and source description |
| `categorical_source_labels` | Optional source labels in palette-row order, retained only as provenance; supplied for SailRain |
| `categorical_colors` | Categorical RGB table, one color per row |
| `waveform_colors` | Ordered waveform RGB table, one color per row |
| `phase_trajectory_color` | One phase-trajectory RGB row |

The loader accepts a character row or string scalar identifying a scheme. IDs start with a lowercase letter and contain only lowercase letters, digits, underscores, or hyphens. It resolves the asset relative to its own file location, independently of MATLAB's current working directory. Keep the skill's `scripts` and `assets` directories together. It reports unknown schemes, invalid JSON, missing required metadata or color fields, and invalid RGB arrays instead of substituting defaults. MATLAB R2020a or later is the compatibility target; distinguish that target from the releases actually used for verification, as documented in the repository README.

## 4. Adding Another Scheme

Add a JSON definition under `assets/color-schemes/` with its own ID and the same required metadata and color fields as SailRain. Preserve meaningful attribution and source notes. Use finite RGB values in the inclusive range `[0, 1]`. If source labels are supplied, match them to categorical palette rows. Palette sizes may differ between schemes; the loader and task configuration must validate their actual capacities.

Register the scheme in the catalog above, document its intended color choices, and add loader and color-assignment checks. Verify explicit overrides, capacity handling, and the final exported colors for affected plot types. Do not copy RGB definitions into MATLAB production scripts or add placeholder schemes for contributors whose colors have not been supplied.
