# Scientific Plotting

A MATLAB-based scientific plotting skill for creating publication-ready figures from existing numerical data. It combines instructions for interpreting and drawing a particular plot type with instructions for arranging that figure in its intended placement.

The skill is organized along two independent dimensions: **plot type** and **placement**. Each dimension can grow as new scientific figures and output contexts are added.

## Two-Dimensional Design

| Dimension | Responsibility | Current options |
| --- | --- | --- |
| Plot type | Input interpretation, plotting behavior, data checks, and export requirements | Independent 2D coordinate plots; pure time series; paired phase trajectory and waveform; categorical bifurcation slices |
| Placement | Target document context, physical dimensions, panel arrangement, margins, and spacing | Full width in a one-column document; one column in a two-column document; spanning both columns in a two-column document |

For each task, select one plot type and one placement. The agent reads the corresponding reference from each dimension and applies both together with the common rules in [SKILL.md](scientific-plotting/SKILL.md). For example, the same time-series workflow can produce a full-width figure for a one-column article or a vertically stacked figure occupying one column of a two-column article.

The default placement is full width in a one-column document. Explicit user dimensions override the corresponding preset fields. The available physical presets are:

| Placement | Available presets |
| --- | --- |
| [One-column document, full width](scientific-plotting/references/placements/one-column-document-full-width.md) | Independent plots with a 60 × 45 mm internal box each: one plot by default, or two side by side when requested, with a text-derived canvas. Four time-series panels on a 148 × 49 mm canvas; four phase/waveform pairs with shared vertical axes within each pair on a 148 × 55 mm canvas; three slices on a 135 × 55.5 mm canvas, with additional rows and height calculated for larger slice layouts. |
| [Two-column document, one column](scientific-plotting/references/placements/two-column-document-single-column.md) | One independent plot with a 60 × 45 mm internal box and a text-derived canvas. Time-series panels stacked vertically, each with a 60 × 12 mm internal plot box and additional space calculated from the actual labels. Other plot types require explicit layout dimensions. |
| [Two-column document, spanning both columns](scientific-plotting/references/placements/two-column-document-spanning.md) | Independent plots with a 60 × 45 mm internal box each: one plot by default, or two side by side when requested, with a text-derived canvas. Other plot types require explicit layout dimensions. |

These presets are this skill's bundled defaults. Confirm any additional journal requirements and resolve missing dimensions before plotting. Slice layouts in either two-column placement require complete geometry, including the canvas, slices, spacing, margins, and colorbar.

For independent plots, the internal box excludes tick text, axis labels, legends, and surrounding annotations. Its 60 × 45 mm dimensions and the default 8 pt Times New Roman text are preserved while margins and any interplot gap are calculated from the actual text. The complete canvas is not fixed at an illustrative overall width such as 70 mm or at another plot type's preset width. Check it against any known available document width; report a conflict rather than shrinking the box or text. A single independent plot may remain compact even when the placement allows the full document width.

## Current Plotting Workflows

| Plot type | Included implementation | Final outputs |
| --- | --- | --- |
| [Independent 2D coordinate plots](scientific-plotting/references/plot-types/independent-2d.md) | Workflow instructions for a task-specific MATLAB script using existing paired coordinates, complete independent axes, and a single or explicitly requested side-by-side arrangement, including scenario guidance for high-density bifurcation scatter plots | Single-page vector PDF and a preview rendered from that PDF at 600 dpi or higher |
| [Pure time series](scientific-plotting/references/plot-types/pure-time-series.md) | Workflow instructions for a task-specific MATLAB script, including time windows, panel labels, and single or explicitly requested split vertical axes | Single-page vector PDF and a preview rendered from that PDF at 600 dpi or higher |
| [Paired phase trajectory and waveform](scientific-plotting/references/plot-types/phase-waveform.md) | Workflow instructions for a task-specific MATLAB script, with a phase trajectory on the left and a waveform on the right, independently configured time windows, and shared or independent vertical axes | Single-page vector PDF and a preview rendered from that PDF at 600 dpi or higher |
| [Categorical bifurcation slices](scientific-plotting/references/plot-types/mat-bifurcation-slices.md) | A reusable MATLAB renderer and a synthetic demo for existing categorical MAT planes, including bifurcation maps and basins of attraction | Editable FIG and a 600 dpi PNG by default; an optional smaller PNG preview |

The independent-plot, time-series, and phase/waveform workflows guide the agent in writing a reproducible script for the supplied data. A one-panel count alone does not select the independent-plot route or change an existing specialized workflow's presets. The bundled slice renderer supports FIG and PNG export.

![Three synthetic categorical slices using the default one-column placement](scientific-plotting/assets/default-three-slice-preview.png)

*The bundled preview shows three synthetic slices, explicitly selecting three colors from the SailRain palette. Its category names and colors illustrate the layout and have no universal scientific meaning.*

## Color Schemes

Color schemes are shared configuration alongside the two workflow dimensions. The default and currently available scheme is **SailRain**, identified by `sailrain`. Its RGB definitions are maintained in one [scheme data file](scientific-plotting/assets/color-schemes/sailrain.json):

| Plot role | SailRain colors |
| --- | --- |
| Categorical slices | A 13-color palette adapted from SailRain's two-dimensional bifurcation plots; choose distinguishable colors for the task rather than automatically taking the first N rows |
| Time-domain waveforms | Red, blue, and black, in that priority order; keep each configured curve's color consistent across panels |
| Independent 2D series | Reuse the ordered waveform palette for general series, without assigning time-domain meaning |
| Phase trajectories | A darker cyan, defined separately from the categorical palette's bright cyan |

Explicit user colors and confirmed task configuration take precedence. Without a specified color configuration, use SailRain. Record the selected palette rows and their mapping to the verified category display order or curve identities. The source category labels in the scheme are provenance only and must not be used to infer category meanings or numeric codes. If more distinct colors are needed than the relevant palette provides, confirm additional colors or another scheme; do not silently cycle, interpolate, or invent colors.

After adding the skill's `scripts/` folder to the MATLAB path, load the scheme with:

```matlab
scheme = load_color_scheme(); % Equivalent to load_color_scheme('sailrain').
selected_palette_rows = [1, 2, 12]; % Explicit selection used by the synthetic demo.
categories.colors = scheme.categorical_colors(selected_palette_rows, :);
```

Supply the matching verified `categories.codes` and `categories.labels` before calling the renderer. The loader also returns `waveform_colors` and `phase_trajectory_color` for task-specific line-plot scripts. The renderer continues to accept explicit RGB arrays and does not load a scheme itself. Fonts, line widths, axes, colorbar placement, and export settings retain their existing rules. See the [color-scheme reference](scientific-plotting/references/color-schemes.md) for the interface, selection rules, and instructions for adding a scheme.

## Requirements

- **MATLAB R2020a or later** is the compatibility target. This is a target, not a claim that every release has been tested; see the release-specific verification status below.
- **Times New Roman** installed for figure text. The default main text size is 8 pt, and the slice renderer reports an error if the requested font is unavailable.
- **Poppler tools**, including `pdfinfo` and `pdftoppm`, for page-size checks and PDF-derived previews in the independent-plot, time-series, and phase/waveform workflows. The slice demo does not require them.
- **An agent that supports local skills**, such as Codex, when using the guided workflow. The MATLAB slice scripts can also be called directly.

The skill instructions, detailed workflow references, MATLAB code comments, and usage examples use American English.

### MATLAB Compatibility

| MATLAB release | Slice PNG export with `export_backend = 'auto'` | Verification status |
| --- | --- | --- |
| R2020a–R2024b | Full-canvas `print`, using explicit paper dimensions and DPI | Compatibility target; not run in these releases |
| R2025a, version 25.1.0.2943329, macOS | Sized `exportgraphics`; the `print` backend can also be selected explicitly | 14 regression checks passed on 2026-10-19: 7 slice checks and 7 color-scheme checks, covering both PNG backends |
| Other newer releases | Sized `exportgraphics` | Compatibility target; not run in these releases |

Independent-plot layout verification on 2026-10-19 used a temporary task script in MATLAB R2025a, version 25.1.0.2943329, with both `print -dpdf -painters` and sized vector `exportgraphics`. Three synthetic cases per backend covered a single plot, long labels with negative ticks and subscripts, and two independent plots side by side. All six final PDFs preserved vector content and embedded Times New Roman with 8 pt main text; measured frames were within 0.1 mm of 60 × 45 mm after correcting export rounding, and the PDF-derived 600 dpi previews were checked for clipping and overlap. Deliberately insufficient available widths were reported while retaining frame and font targets. These checks do not certify older MATLAB releases.

The renderer uses `ax.CLim` rather than the newer `clim` function name. It selects an export path that preserves the full physical canvas, including margins. The sizing and padding options used by [`exportgraphics`](https://www.mathworks.com/help/matlab/ref/exportgraphics.html) require R2025a or later; older releases use [`print`](https://www.mathworks.com/help/matlab/ref/print.html) instead. Explicit `export_backend = 'exportgraphics'` therefore requires R2025a or later. `export_backend = 'print'` is available for compatibility checks and manual selection on newer releases too.

Running the `print` backend on R2025a checks that export path on R2025a; it does not constitute an execution test on R2020a–R2024b. The line-plot workflows also permit full-canvas vector PDF export through `print` when the installed release cannot preserve the required canvas with `exportgraphics`. Final PDF page dimensions and internal plot-box dimensions still require separate measurement and, where necessary, correction for MATLAB coordinate rounding; choosing a backend alone does not establish dimensional acceptance.

### Environment Checks

Before rendering, check the font in MATLAB:

```matlab
assert(any(strcmpi(listfonts, 'Times New Roman')), ...
    'Install Times New Roman before rendering these figures.');
```

If the font is missing, install it through your operating system's font manager or explicitly agree on a different font for the task. Do not silently substitute one. For the line-plot PDF checks, install Poppler through your platform's package manager and make its executables available on `PATH`. Verify them from your terminal:

```text
pdfinfo -v
pdftoppm -v
```

These PDF tools are not needed for the slice renderer or its demo.

## Use as a Codex Skill

Copy the entire `scientific-plotting/` directory into your research project's `.agents/skills/` directory. You can copy the folder with your file manager on any platform. The following shell commands are an alternative on macOS and Linux, run from this repository's root:

```bash
mkdir -p /path/to/your/project/.agents/skills
cp -R scientific-plotting /path/to/your/project/.agents/skills/
cp LICENSE /path/to/your/project/.agents/skills/scientific-plotting/
```

For a user-wide installation, use `~/.agents/skills/` as the destination and include the license in the installed skill folder. Keep its `SKILL.md`, `references/`, `scripts/`, `assets/`, and `agents/` files together. See the [official Codex skill documentation](https://developers.openai.com/codex/skills/) for discovery locations and invocation details. If the newly installed skill does not appear, restart Codex.

For an agent without local skill discovery, provide `scientific-plotting/SKILL.md` as the workflow instructions, with access to the supplied data and a MATLAB runtime.

Invoke `$scientific-plotting` and specify the plot type, placement, source files, variable mappings, units, desired ranges, and output location. Include file order, colors, category definitions, and physical dimensions when relevant. For example:

**One independent plot**

```text
Use $scientific-plotting to create an independent 2D coordinate plot from
data/coordinates.csv, occupying one column in a two-column article.
Use input_V and response_V as paired coordinates, both in volts, and
connect the samples in their original order. The available column width
for this task is 88.5 mm. Keep the default internal frame and text size.
Write the MATLAB script, vector PDF, and PDF-derived preview to results/independent/.
```

**Two independent plots side by side**

```text
Use $scientific-plotting to place independent plots from data/first.csv
and data/second.csv side by side, in that order, spanning both columns
of a two-column article. Each file has paired position_mm and force_N
columns. Keep complete axes and independent ranges on both plots.
Use the default internal frame for each plot and calculate the canvas
from the actual labels. Write the MATLAB script, vector PDF, and
PDF-derived preview to results/independent_pair/.
```

**High-density bifurcation scatter**

```text
Use $scientific-plotting to create a high-density bifurcation scatter plot
from the existing paired parameter and retained_sample columns in
data/bifurcation_samples.csv, occupying one column of a two-column article.
Use the variable definitions and units in data/metadata.txt and keep the
default internal frame. Apply the scenario's starting combination:
LineStyle = 'none', Marker = 'o', MarkerSize = 0.20 pt,
MarkerFaceColor = seriesColor, and MarkerEdgeColor = 'none'.
Choose seriesColor using the existing shared color rules. Retain every
original sample and its parameter pairing. Inspect the actual frame and
local density in the exported figure; adjust the starting marker size
when needed rather than determining it from the total point count.
Write the reproducible MATLAB script, single-page vector PDF, and PNG
rendered from that same PDF at 600 dpi or higher to results/bifurcation_scatter/.
```

**Pure time series**

```text
Use $scientific-plotting to plot data/voltage.csv as a pure time series
occupying one column of a two-column article. Use time_s for time in seconds
and voltage_V for voltage in volts. Show 0.2 to 0.4 s with a blue curve.
Write the MATLAB script, vector PDF, and PDF-derived preview to results/voltage/.
```

**Paired phase trajectory and waveform**

```text
Use $scientific-plotting to create four phase-trajectory-and-waveform pairs
from data/run_1.csv through data/run_4.csv, in that order. Use the full-width
placement for a one-column article. Each file contains time_s, x_V, and y_V.
Use x_V as the horizontal coordinate and y_V as the vertical coordinate of
each phase plot; plot y_V against time_s in each waveform. Both variables
are voltages in volts; use 1 to 2 s for both views and black curves.
Write the reproducible script and final figures to results/phase/.
```

**Categorical slices**

```text
Use $scientific-plotting to render data/map_1.mat, data/map_2.mat, and
data/map_3.mat as categorical slices, in that order, with the full-width
placement for a one-column article. Use the coordinate vectors, matrix
orientation, category definitions, and colors documented in data/metadata.txt.
Write the adapter script, editable FIG, and 600 dpi PNG to results/slices/.
```

Relative data and output paths in these requests refer to the research project. Keep source data, task-specific scripts, and generated figures outside the installed skill directory.

### Place Independent Figures at Native Size in LaTeX

The default frame dimensions and 8 pt text refer to the PDF's native physical size. Once its measured total width fits the intended column or document width, include it without a resizing option:

```latex
% In the preamble:
\usepackage{graphicx}

% In the document:
\begin{figure}[!t]
\centering
\includegraphics{figures/independent_plot.pdf}
\caption{A task-specific description.}
\end{figure}
```

Use `figure*` instead of `figure` for a figure spanning both columns. Setting `width=\columnwidth` or `width=\textwidth` changes the frame dimensions and text size unless the PDF already has exactly that width; do not use it to imply that the original dimensions are preserved. If the figure does not fit, resolve the layout constraints before placing it. The single- and two-plot examples do not impose a universal journal column width.

## Run the MATLAB Demo

Set `skill_root` to the actual skill directory, then run:

```matlab
skill_root = '/absolute/path/to/scientific-plotting-skill/scientific-plotting';
addpath(fullfile(skill_root, 'scripts'), '-begin');
which render_bifurcation_slices

output_dir = tempname(tempdir);
[fig, ax, cb] = demo_bifurcation_slices(3, output_dir);
```

The demo creates three small synthetic MAT files, reloads them through an explicit field mapping, and renders three slices. The output directory contains:

- `synthetic_slice_01.mat`, `synthetic_slice_02.mat`, and `synthetic_slice_03.mat`.
- `demo_3_slices.fig`, an editable MATLAB figure.
- `demo_3_slices.png`, the main 600 dpi export.
- `demo_3_slices_preview.png`, a smaller preview approximately 1,000 pixels wide.

The no-argument call, `demo_bifurcation_slices()`, creates **five** slices in a new unique directory under MATLAB's `tempdir` and prints that directory's path. The default does not depend on MATLAB's current working directory. An explicitly supplied output directory is used as provided; keep it outside the installed skill.

The demo loads the SailRain scheme and explicitly selects palette rows `[1, 2, 12]`, retaining the gray, bright cyan, and magenta colors shown in the bundled preview. This selection is an example, not a rule for all three-category datasets.

These synthetic inputs demonstrate plotting and layout only. They are not simulation results, measurements, or evidence of dynamical behavior.

## Slice Renderer Interface

After adapting your verified data to the required structures, call:

```matlab
[fig, ax, cb] = render_bifurcation_slices(slices, categories, options);
```

| Input | Required contents |
| --- | --- |
| `slices` | A nonempty struct vector. Each element has coordinate vectors `x` and `y`, plus a categorical matrix `S` with size `[numel(y), numel(x)]`. Optional fields are `title`, `source_file`, and a scalar `metadata` struct. |
| `categories` | A scalar struct containing unique numeric `codes`, matching display `labels`, and an N × 3 RGB `colors` array with values in `[0, 1]`. Their order determines the shared colorbar order from bottom to top. |
| `options` | An optional scalar struct for layout, axis labels, display ranges, typography, and export settings. Unknown option names are rejected. |

Coordinates must already be in display units, finite, and strictly increasing, with at least two points per axis. **Rows of `S` correspond to `y`; columns correspond to `x`.** Different slices may use different grid sizes and nonuniform sampling. Every matrix entry must be finite and covered by `categories.codes`.

The renderer preserves each original classification sample as a flat colored cell, including the last row and column. All slices share one colorbar, so their category definitions and colors must be consistent. It returns an editable `fig`, one shared physical drawing axis `ax`, and the colorbar `cb`.

Frequently used options include:

| Options | Purpose |
| --- | --- |
| `columns`, `slice_width_mm`, `slice_height_mm`, `slice_drop_mm` | Number of columns and slice geometry |
| `slice_gap_mm`, `row_gap_mm`, `margins_mm` | Spacing and margins; margin order is `[left, bottom, right, top]` |
| `figure_mm`, `colorbar_mm` | Canvas `[width, height]` and colorbar `[left, bottom, width, height]`, in millimeters |
| `x_limits`, `y_limits`, `x_ticks`, `y_ticks`, `x_label`, `y_label` | Coordinate display and labeling |
| `output_prefix`, `formats`, `resolution`, `preview_width_px` | Output path without an extension, FIG/PNG format selection, resolution, and optional preview width |
| `export_backend` | `auto` (default), `exportgraphics`, or `print`; the selected PNG backend is recorded in `fig.UserData.export_backend` |

An empty `output_prefix` creates a figure without writing files. With a nonempty prefix, the defaults export FIG and PNG at 600 dpi. The renderer's layout defaults implement the one-column-document placement; provide complete placement-specific geometry for either two-column context.

See the [slice workflow reference](scientific-plotting/references/plot-types/mat-bifurcation-slices.md) for MAT adaptation and detailed checks, and [the renderer](scientific-plotting/scripts/render_bifurcation_slices.m) for the complete `default_options` definition.

## Data Preservation and Verification

- Treat original files as read-only and preserve their verified sample order, category definitions, and provenance. Default rendering uses the original samples without interpolation, smoothing, or downsampling.
- Confirm variables, units, coordinate orientation, and category meanings from the actual source. Keep unit conversions and display mappings explicit in the task-specific adapter.
- Use existing data for plotting. Simulation, model changes, numerical solving, classification design, and dynamical interpretation fall outside the current workflows.
- Check the selected samples or category cells, figure dimensions, fonts, labels, colors, and output files. Inspect a high-resolution rendering for clipping, overlap, and unnecessary whitespace. Explicit millimeter dimensions have a 0.1 mm tolerance.
- Follow the selected plot type's export checks: inspect the final vector PDF and its derived preview for line plots; inspect the exported PNG and reopened editable FIG for slices.

## Extending the Skill

Extend the two dimensions independently:

1. **Add a plot type** under `scientific-plotting/references/plot-types/`, defining its input contract, rendering behavior, outputs, and verification. Add reusable MATLAB scripts when the workflow benefits from them.
2. **Add a placement** under `scientific-plotting/references/placements/`, defining the target context, dimensions, arrangement, and required user inputs. Presentation slides and other output contexts are possible future placements.
3. Register the new route in `SKILL.md` and document any compatibility requirements between the new reference and existing references. Update examples and verification as needed.

The current package supplies the four plot types and three article placements listed above. Additional plot families and presentation-oriented placements remain future extensions.

To add a color scheme, add its JSON definition and document it in the shared [color-scheme reference](scientific-plotting/references/color-schemes.md), with appropriate verification. Only SailRain is bundled; additional authors' schemes can be added when their colors are supplied.

## Run the Regression Checks

The repository includes MATLAB checks for color-scheme data and loading, explicit color overrides, both PNG export backends, layouts, category-cell preservation, FIG editability, invalid inputs, and demo output directories:

```matlab
repo_root = '/absolute/path/to/scientific-plotting-skill';
results = runtests(fullfile(repo_root, 'tests'));
assert(all([results.Passed]), 'Plotting regression checks failed.');
```

Tests require Times New Roman and write outputs to new temporary directories. The main output directory is printed so that high-resolution files can also be inspected visually. Running these checks in an older MATLAB release is required before claiming that release has been tested.

## Repository Layout

```text
.
├── .gitignore
├── LICENSE
├── README.md
├── tests/
│   ├── test_bifurcation_slices.m
│   └── test_color_schemes.m
└── scientific-plotting/
    ├── SKILL.md
    ├── agents/
    │   └── openai.yaml
    ├── assets/
    │   ├── color-schemes/
    │   │   └── sailrain.json
    │   └── default-three-slice-preview.png
    ├── references/
    │   ├── color-schemes.md
    │   ├── placements/
    │   └── plot-types/
    └── scripts/
        ├── demo_bifurcation_slices.m
        ├── load_color_scheme.m
        └── render_bifurcation_slices.m
```

## License

Copyright (c) 2026 Pierson Bian. Released under the [MIT License](LICENSE).
