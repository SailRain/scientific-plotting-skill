# MAT Bifurcation and Categorical Plane Slice Workflow

Read this file only when rendering existing MAT two-dimensional categorical planes, such as bifurcation maps or basins of attraction, as sheared slices. Also apply the [scientific plotting workflow](../../SKILL.md) and the selected placement file. This plot type includes a [renderer](../../scripts/render_bifurcation_slices.m), a [synthetic demo](../../scripts/demo_bifurcation_slices.m), and a [default visual preview](../../assets/default-three-slice-preview.png).

The current workflow focuses on faithfully displaying existing data. Do not run simulations, reclassify data, design classification criteria, or infer dynamical mechanisms. MATLAB R2025a or later supports the explicit export-dimension options used by the renderer; verify compatibility before using other versions.

## 1. Data Sources and Applicability

- Inspect the user-specified MAT files, metadata, and applicable existing programs first. Do not infer categories, fields, units, parameters, figure count, or grids from reference examples.
- The current renderer supports numeric category codes and one shared discrete colorbar. Separate colorbars, continuous numerical planes, RGB images, legends, or missing-value masks require selecting or extending the implementation for the specific task. Do not treat each continuous value as a category or infer classifications from RGB colors.
- Write a small data-adaptation entry point in the user's working directory and save results to an explicit output directory. Treat the original MAT files as read-only. Do not write real data or generated results into the skill directory, and preserve applicable existing program interfaces.
- Before running, load only this skill's `scripts` directory or one explicitly selected tool directory, and verify the resolved path with `which render_bifurcation_slices` to avoid mixing in functions with the same name from locations such as `PROG6`.

## 2. Verify Data and Display Semantics

1. Inspect matrices, coordinates, metadata, and any necessary data-generation programs in the user-specified order. Identify conflicting sources. Ask about meanings that cannot be determined; do not infer periods, attractors, units, or parameters from filenames, screenshots, or numerical codes.
2. Use classification criteria from the current data and verified documentation exclusively. For data classified only through P6, do not automatically add P7–P9 or infer that the remaining codes mean MP. Do not interpret basin-of-attraction codes as period counts. If only the semantics are missing and the user accepts code labels, faithfully label the original codes without inventing names.
3. Store original codes, source category names, display names, display order, and RGB colors separately. Display aliases change labels only and do not modify classifications. Merging categories again or changing thresholds falls outside this plotting workflow.
4. The renderer requires rows of `S` to correspond to `y` and columns to `x`. A square matrix's dimensions do not establish its orientation. When coordinate grids are available, check them against the coordinate vectors; otherwise, verify orientation from the data documentation or generation program.
5. Perform coordinate conversions in the adapter. Slices may use different grid sizes and nonuniform sampling; each axis must have at least two finite, strictly increasing points. After confirming orientation, reverse descending coordinates together with the corresponding matrix rows or columns; do not sort only the coordinate vectors.
6. Before plotting, check required fields, matrix dimensions, and category-code coverage. The renderer rejects NaN, Inf, and codes absent from the category table. To display missing data, verify its meaning first, then explicitly configure a separate category or extend mask handling; do not fold it into an arbitrary existing category.

## 3. MATLAB Interface

```matlab
[fig, ax, cb] = render_bifurcation_slices(slices, categories, options);
```

`slices` is a nonempty struct vector whose elements contain:

| Field | Contents |
|---|---|
| `x`, `y` | Coordinate vectors in display units; at least two finite, strictly increasing samples per axis |
| `S` | Matrix of discrete category codes, with rows corresponding to `y` and columns to `x` |
| `title` | Optional slice parameter text; do not include the automatically generated panel label |
| `source_file` | Optional source path for traceability |
| `metadata` | Optional scalar struct recording unit conversions, parameters, or source information |

`categories` is a scalar struct:

- `codes`: a vector of unique numeric codes, which may be nonconsecutive;
- `labels`: display labels with the same length as the code vector;
- `colors`: an `N×3` RGB table in the same order as the codes.

The returned `fig` is an editable figure, `ax` is the shared physical drawing axis containing all slices, and `cb` is the shared colorbar. `ax` is not an array of individual axes for the slices.

## 4. Category Mapping and Shared Colorbar

- Determine category counts, names, colors, and order from the user's requirements and the data. Do not prescribe specific categories or a maximum period. When no colors are specified, choose distinguishable colors and record the configuration without adopting the meanings of example codes.
- The colorbar may retain the complete verified category definition or list only the categories actually present in the current data. When the user does not specify, retain complete category metadata if available to support comparison; otherwise, use the verified categories actually present. Both approaches must cover every plotted sample.
- `codes`, `labels`, and `colors` correspond one to one, with their order determining the colorbar order from bottom to top. The renderer explicitly maps original codes to `1:N`, using `CLim = [0.5, N+0.5]` and `Ticks = 1:N` to align labels with the centers of color blocks.
- When the user specifies display aliases, retain source names for data verification and change only `labels`. Reorder codes, labels, and colors together.
- A shared colorbar is appropriate only when category semantics and color mappings are consistent across slices. Equivalent meanings with different codes may be explicitly mapped in the adapter. Do not force different meanings into one definition to share a colorbar.
- By default, place the colorbar on the right, center labels on the color blocks, omit short tick marks, and fix `AxisLocation = 'out'`. For many categories or long labels, increase colorbar space, margins, or canvas height without reducing the default font size.

The following illustrates the interface only and assigns no universal meaning to the codes or colors:

```matlab
categories.codes = [-4, 7, 42];
categories.labels = {'Zone A', 'Zone B', 'Zone C'};
categories.colors = [0.45,0.45,0.45; 0,1,1; 1,0.10,1];
```

## 5. Complete Cells and Slice Rendering

- Render discrete categories as flat colored cells without interpolation, smoothing, or downsampling. The renderer uses `surface`, `FaceColor = 'flat'`, and `EdgeColor = 'none'`, converting `ny×nx` samples to `(ny+1)×(nx+1)` vertices so that every sample has its own colored face and the last row and column are retained.
- Place cell boundaries at the midpoints between adjacent coordinate samples, with the outermost boundaries stopping at the original coordinate endpoints. Generate sheared slices with a two-dimensional affine shear; configure coordinate ranges separately from physical geometry.
- When display ranges are unspecified, use the exact endpoints of the union of coordinates across all slices. Do not apply the `3%` padding used for line plots. Explicit ranges may be larger but must not silently crop any slice samples.
- By default, generate panel labels such as `(a)` and `(b)` in input order. Place them above the slices together with any optional slice parameter text, rotated to match the shear angle. Continue with labels such as `(aa)` after 26 slices.
- Use manually drawn parallelogram borders, a shared hidden physical drawing axis, and a white background. Do not apply the four-sided plot boxes, `innerposition`, or labels inside plot boxes used for line plots.

## 6. Placement and options

Physical dimensions are specified solely by the selected placement file. The renderer's physical default fields implement the [full-width placement for a one-column document](../placements/one-column-document-full-width.md); these defaults may be used directly when no placement is specified. For either two-column placement, obtain the complete dimensions required by its file first and set them explicitly in `options`. Do not allow one-column defaults to carry over into two-column figures.

`options` is a scalar struct. Omitted fields use renderer defaults, and unknown fields produce an error so that misspelled options are not ignored. Common fields are:

| Field | Purpose |
|---|---|
| `columns` | Number of slices per row |
| `slice_width_mm`, `slice_height_mm` | Physical width and height of each slice |
| `slice_drop_mm`, `slice_gap_mm`, `row_gap_mm` | Shear drop, gap between slices, and gap between rows |
| `margins_mm` | Physical margins in `[left,bottom,right,top]` order |
| `figure_mm`, `colorbar_mm` | Canvas `[width,height]` and colorbar `[left,bottom,width,height]` |
| `x_limits`, `y_limits` | Shared display ranges; empty values use the union of coordinates across all slices |
| `x_ticks`, `y_ticks` | Shared ticks; empty values generate them automatically within the display range |
| `x_label`, `y_label` | Coordinate variables and units |
| `font_name`, `font_size_pt` | Font and font size; defaults follow the main workflow |
| `panel_labels` | Panel-label list; empty values generate labels automatically in input order |
| `title_interpreter`, `label_interpreter` | `none` or `tex` |
| `x_label_offset_mm`, `y_label_offset_mm`, `x_tick_offset_mm`, `y_tick_offset_mm`, `title_offset_mm`, `tick_length_mm` | Independent millimeter offsets for horizontal and vertical labels, tick text, titles, and tick marks |
| `border_color`, `line_width_pt` | Parallelogram border color and line width |
| `output_prefix` | Output path and filename without an extension; an empty value creates a figure only |
| `formats`, `resolution` | `fig`, `png`, and export resolution |
| `visible`, `preview_width_px` | Figure visibility and optional preview width |

When text overlaps, adjust spacing, margins, the colorbar, and the canvas first, retaining the default font and font size. For all field definitions, use the help text and `default_options` in the [renderer](../../scripts/render_bifurcation_slices.m).

## 7. Real MAT Adaptation and Demo

Verify field meanings, units, and matrix orientation before constructing the interface. For example, when `par_x` is confirmed to be in A, `par_y` in Hz, and rows of `S` correspond to frequency:

```matlab
saved = load(input_file, 'par_x', 'par_y', 'S');
slices(1).x = saved.par_x * 1e3;
slices(1).y = saved.par_y;
slices(1).S = saved.S;
slices(1).title = 'Example parameter label';
slices(1).source_file = input_file;
options.x_label = '{\it A}, mA';
options.y_label = '{\it f}, Hz';
options.output_prefix = fullfile(program_dir, 'output', 'my_slices', 'my_slices');
[fig, ax, cb] = render_bifurcation_slices(slices, categories, options);
```

The actual entry point must explicitly configure the variables in this example; do not discover or guess them automatically. Set the actual directory before calling the skill tools:

```matlab
skill_root = '/path/to/scientific-plotting';
addpath(fullfile(skill_root, 'scripts'), '-begin');
which render_bifurcation_slices
[fig, ax, cb] = demo_bifurcation_slices();
[fig, ax, cb] = demo_bifurcation_slices(3, fullfile(pwd, 'output', 'three_slices'));
```

By default, the demo draws five small synthetic categorical planes. The figure count and output directory may also be specified. When no output directory is provided, it writes to `output/bifurcation_slice_demo/` under the current working directory. It verifies only the plotting interface and layout, does not depend on real research data, and does not constitute simulation results or evidence of dynamical behavior.

## 8. Export, Acceptance Checks, and Reporting

- When `output_prefix` is empty, create a figure only. Otherwise, the default exports are an editable FIG and a native MATLAB `600 dpi` PNG. The current renderer supports only `fig`, `png`, or both. This plot type does not require a PDF, and its PNG does not originate from a PDF.
- Export with the physical width and height specified by the placement and a white background. Optional `preview_width_px` generates a lower-resolution copy for visual inspection. The preview retains the main figure's physical dimensions and reduces only DPI; it does not replace the high-resolution PNG.
- Check file order, sources, matrix orientation, original-code-to-display-index mappings, and all samples, with particular attention to nonuniform grids and the last row and column. Invalid codes, incorrect dimensions, and cropping display ranges must produce explicit errors.
- Verify category names, aliases, colors, order, and alignment with colorbar centers. Do not validate real data against the example category table.
- Check consistency between exported pixels, physical dimensions, and DPI, allowing small differences from integer DPI and pixel rounding. Reopen the FIG to confirm that slices, text, and the colorbar remain editable.
- Inspect the high-resolution PNG and reopened FIG for clipped or overlapping text, the longest colorbar labels, boundary samples, and spacing between rows. Adjust any issues, then export and inspect again.
- When modifying the general renderer, cover single-slice, three-slice, multirow, different-grid, and custom-category cases. When changing only the layout or adapter entry point, run the relevant checks. Provide program and output links, and distinguish plotting checks from numerical verification of dynamics.

The [synthetic three-slice preview](../../assets/default-three-slice-preview.png) illustrates only the default one-column visual layout. Its category names, codes, and colors are not requirements for other datasets.
