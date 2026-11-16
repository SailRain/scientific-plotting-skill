function [fig, ax, cb] = render_bifurcation_slices(slices, categories, options)
%RENDER_BIFURCATION_SLICES Render existing categorical planes as slice plots.
%   Supply SLICES with x, y, S, and optional title, source_file, and metadata.
%   S rows represent y. CATEGORIES contains matching codes, labels, and RGB
%   colors. The optional OPTIONS struct configures geometry and export.
%   Omitted slice dimensions are 23 mm wide, 27 mm high, and 8 mm drop.
%   OPTIONS.x_text_mode defaults to 'each-slice'. Use 'bottom-per-column'
%   for confirmed shared x axes. See also RENDER_SLICE_PLOTS for placement.
%   A nonempty output_prefix exports the requested formats (FIG and native
%   600 dpi PNG by default). An empty prefix draws without exporting.

if nargin < 3
    options = struct();
end
[fig, ax, cb] = render_slice_plot_figure(slices, categories, options, []);
end
