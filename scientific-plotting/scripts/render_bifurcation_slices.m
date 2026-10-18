function [fig, ax, cb] = render_bifurcation_slices(slices, categories, options)
%RENDER_BIFURCATION_SLICES Render saved categorical maps as sheared slices.
%   SLICES is a struct vector with x, y, S, and optional title, source_file,
%   metadata. Coordinates are already in display units; S rows represent y.
%   CATEGORIES contains equally ordered codes, labels, and RGB colors.
%   OPTIONS is an optional scalar struct; see default_options below for all
%   settings. Unknown settings are rejected to catch misspelled options.
%   An empty output_prefix opens a figure without writing files. A nonempty
%   prefix exports the requested formats. MATLAB R2025a or later is required
%   for explicit export dimensions. No classification or simulation is run.

if nargin < 3
    options = struct();
end
options = merge_options(options);
[slices, categories] = validate_inputs(slices, categories);
count = numel(slices);
category_count = numel(categories.codes);
options = resolve_layout(slices, category_count, options);
validate_options(options, count, category_count);

fig = figure('Visible', 'off', 'Color', 'w', 'Name', options.figure_name, ...
    'NumberTitle', 'off', 'Units', 'centimeters', ...
    'Position', [2, 2, options.figure_mm / 10], 'GraphicsSmoothing', 'off', ...
    'InvertHardcopy', 'off', 'DefaultAxesFontName', options.font_name, ...
    'DefaultAxesFontSize', options.font_size_pt, ...
    'DefaultTextFontName', options.font_name, ...
    'DefaultTextFontSize', options.font_size_pt);
try
    ax = axes('Parent', fig, 'Units', 'normalized', 'Position', [0, 0, 1, 1], ...
        'XLim', [0, options.figure_mm(1)], 'YLim', [0, options.figure_mm(2)], ...
        'ZLim', [-1, 1], 'YDir', 'normal', 'Visible', 'off', ...
        'FontName', options.font_name, 'FontSize', options.font_size_pt, ...
        'LabelFontSizeMultiplier', 1, 'TitleFontSizeMultiplier', 1, ...
        'DataAspectRatio', [1, 1, 1], 'SortMethod', 'childorder');
    ax.Toolbar.Visible = 'off';
    disableDefaultInteractivity(ax);
    hold(ax, 'on');
    view(ax, 2);
    colormap(ax, categories.colors);
    clim(ax, [0.5, category_count + 0.5]);

    row_count = ceil(count / options.columns);
    row_pitch = options.slice_height_mm + options.slice_drop_mm + options.row_gap_mm;
    content_height = row_count * (options.slice_height_mm + options.slice_drop_mm) ...
        + (row_count - 1) * options.row_gap_mm + sum(options.margins_mm([2, 4]));
    extra_height = options.figure_mm(2) - content_height;
    origins = zeros(count, 2);
    for k = 1:count
        column = mod(k - 1, options.columns);
        row = floor((k - 1) / options.columns);
        origin = [options.margins_mm(1) + column * ...
            (options.slice_width_mm + options.slice_gap_mm), ...
            options.margins_mm(2) + options.slice_drop_mm + ...
            (row_count - row - 1) * row_pitch + extra_height / 2];
        origins(k, :) = origin;
        [gx, gy] = meshgrid(sample_edges(slices(k).x), sample_edges(slices(k).y));
        [px, py] = coordinates(gx, gy, origin, options);
        [~, indices] = ismember(slices(k).S, categories.codes);
        % Every original sample owns one flat face. Only the unused last
        % vertex row/column is padded, so no boundary sample is discarded.
        colors = indices([1:end, end], [1:end, end]);
        h = surface(ax, px, py, zeros(size(px)), colors, ...
            'CDataMapping', 'scaled', 'FaceColor', 'flat', 'EdgeColor', 'none', ...
            'FaceLighting', 'none', 'Tag', sprintf('bifurcation_slice_%d', k));
        provenance = slices(k).metadata;
        provenance.source_file = slices(k).source_file;
        provenance.sample_size = size(indices);
        provenance.category_codes = categories.codes;
        h.UserData = provenance;
        draw_labels(ax, origin, k, column == 0, slices(k).title, options);
    end

    cb = colorbar(ax, 'Location', 'eastoutside', 'Ticks', 1:category_count, ...
        'TickLabels', categories.labels, 'TickLabelInterpreter', 'none', ...
        'FontName', options.font_name, 'FontSize', options.font_size_pt, ...
        'TickLength', 0, 'Color', 'k', 'LineWidth', options.line_width_pt, 'Box', 'on');
    cb.Direction = 'normal';
    cb.Units = 'normalized';
    cb.Position = options.colorbar_mm ./ options.figure_mm([1, 2, 1, 2]);
    ax.Position = [0, 0, 1, 1];
    % Manual positions can trigger automatic labels on the inner side in
    % tall layouts. Pin the labels to the outer/right side of this bar.
    cb.AxisLocation = 'out';
    fig.UserData = struct('layout', options, 'origins_mm', origins, ...
        'category_codes', categories.codes, 'category_labels', {categories.labels}, ...
        'source_files', {{slices.source_file}});
    drawnow;
    check_text_bounds(ax, cb, categories.labels, options);
    assert(isequal(cb.Limits, [0.5, category_count + 0.5]), ...
        'BifurcationSlices:ColorbarAlignment', 'Colorbar limits do not match the display bins.');
    assert(strcmp(cb.AxisLocation, 'out') && strcmp(cb.AxisLocationMode, 'manual'), ...
        'BifurcationSlices:ColorbarSide', 'Colorbar labels must stay on the outer side.');
    fig.Visible = options.visible;
    export_outputs(fig, options);
    fprintf('Rendered %d slices and %d category samples without interpolation.\n', ...
        count, sum(arrayfun(@(s) numel(s.S), slices)));
catch exception
    if isgraphics(fig)
        close(fig);
    end
    rethrow(exception);
end
end

function options = default_options()
options = struct( ...
    'columns', [], 'slice_width_mm', 34.5, 'slice_height_mm', 36, ...
    'slice_drop_mm', 9.75, 'slice_gap_mm', 2.25, 'row_gap_mm', 9.75, ...
    'margins_mm', [10.5, 5.25, 16.5, 4.5], ...
    'figure_mm', [], 'colorbar_mm', [], ...
    'x_limits', [], 'y_limits', [], 'x_ticks', [], 'y_ticks', [], ...
    'x_label', 'x', 'y_label', 'y', 'panel_labels', {{}}, ...
    'font_name', 'Times New Roman', 'font_size_pt', 8, ...
    'label_interpreter', 'tex', 'title_interpreter', 'none', ...
    'x_label_offset_mm', 5.1, 'y_label_offset_mm', 8, ...
    'x_tick_offset_mm', 1, 'y_tick_offset_mm', 1.1, 'title_offset_mm', 2.1, ...
    'tick_length_mm', 0.6, 'border_color', [0.65, 0.72, 0.77], 'line_width_pt', 0.4, ...
    'figure_name', 'Bifurcation slices', 'visible', 'on', ...
    'output_prefix', '', 'formats', {{'fig', 'png'}}, ...
    'resolution', 600, 'preview_width_px', []);
end

function options = merge_options(given)
assert(isstruct(given) && isscalar(given), 'BifurcationSlices:InvalidOptions', ...
    'Options must be a scalar struct.');
options = default_options();
names = fieldnames(given);
unknown = setdiff(names, fieldnames(options));
assert(isempty(unknown), 'BifurcationSlices:UnknownOption', ...
    'Unknown option: %s', strjoin(unknown, ', '));
for k = 1:numel(names)
    options.(names{k}) = given.(names{k});
end
end

function [slices, categories] = validate_inputs(slices, categories)
assert(isstruct(slices) && isvector(slices) && ~isempty(slices) && ...
    all(isfield(slices, {'x', 'y', 'S'})), 'BifurcationSlices:InvalidSlices', ...
    'Slices must be a nonempty struct vector with x, y, and S fields.');
assert(isstruct(categories) && isscalar(categories) && ...
    all(isfield(categories, {'codes', 'labels', 'colors'})), ...
    'BifurcationSlices:InvalidCategories', 'Categories must contain codes, labels, and colors.');
validateattributes(categories.codes, {'numeric'}, {'real', 'vector', 'finite', 'nonempty'});
categories.codes = double(categories.codes(:).');
labels = string(categories.labels);
assert(isvector(labels) && all(~ismissing(labels) & strlength(labels) > 0) && ...
    numel(labels) == numel(categories.codes) && ...
    numel(unique(categories.codes)) == numel(categories.codes), ...
    'BifurcationSlices:InvalidCategories', 'Category codes must be unique with one nonempty label per code.');
categories.labels = cellstr(labels(:).');
validateattributes(categories.colors, {'numeric'}, ...
    {'real', 'finite', 'size', [numel(labels), 3], '>=', 0, '<=', 1});
categories.colors = double(categories.colors);
for k = 1:numel(slices)
    validateattributes(slices(k).x, {'numeric'}, {'real', 'finite', 'vector'});
    validateattributes(slices(k).y, {'numeric'}, {'real', 'finite', 'vector'});
    slices(k).x = double(slices(k).x(:).');
    slices(k).y = double(slices(k).y(:));
    assert(numel(slices(k).x) >= 2 && numel(slices(k).y) >= 2 && ...
        all(diff(slices(k).x) > 0) && all(diff(slices(k).y) > 0), ...
        'BifurcationSlices:InvalidCoordinates', 'Slice %d coordinates must be strictly increasing, with at least two points.', k);
    assert((isnumeric(slices(k).S) || islogical(slices(k).S)) && isreal(slices(k).S) && ...
        isequal(size(slices(k).S), [numel(slices(k).y), numel(slices(k).x)]), ...
        'BifurcationSlices:InvalidGrid', 'Slice %d rows must represent y and columns x.', k);
    slices(k).S = double(slices(k).S);
    assert(all(isfinite(slices(k).S(:))) && all(ismember(slices(k).S(:), categories.codes)), ...
        'BifurcationSlices:InvalidCategory', 'Slice %d contains missing or unknown categories; provide an explicit missing-data mapping.', k);
    if ~isfield(slices, 'title') || isempty(slices(k).title)
        slices(k).title = '';
    end
    if ~isfield(slices, 'source_file') || isempty(slices(k).source_file)
        slices(k).source_file = '';
    end
    if ~isfield(slices, 'metadata') || isempty(slices(k).metadata)
        slices(k).metadata = struct();
    end
    assert(isstruct(slices(k).metadata) && isscalar(slices(k).metadata), ...
        'BifurcationSlices:InvalidMetadata', 'Slice metadata must be a scalar struct.');
    slices(k).title = text_scalar(slices(k).title, 'title');
    slices(k).source_file = text_scalar(slices(k).source_file, 'source_file');
end
end

function options = resolve_layout(slices, category_count, options)
count = numel(slices);
if isempty(options.columns)
    options.columns = min(3, count);
end
validateattributes(options.columns, {'numeric'}, {'scalar', 'integer', 'positive', 'finite'});
options.columns = min(options.columns, count);
positive = {'slice_width_mm', 'slice_height_mm', 'font_size_pt'};
for k = 1:numel(positive)
    validateattributes(options.(positive{k}), {'numeric'}, {'scalar', 'real', 'positive', 'finite'});
end
nonnegative = {'slice_drop_mm', 'slice_gap_mm', 'row_gap_mm'};
for k = 1:numel(nonnegative)
    validateattributes(options.(nonnegative{k}), {'numeric'}, {'scalar', 'real', 'nonnegative', 'finite'});
end
validateattributes(options.margins_mm, {'numeric'}, {'real', 'finite', 'size', [1, 4], 'nonnegative'});
rows = ceil(count / options.columns);
minimum_width = options.margins_mm(1) + options.columns * options.slice_width_mm + ...
    (options.columns - 1) * options.slice_gap_mm + options.margins_mm(3);
minimum_height = sum(options.margins_mm([2, 4])) + ...
    rows * (options.slice_height_mm + options.slice_drop_mm) + (rows - 1) * options.row_gap_mm;
bar_height = max(options.slice_height_mm + options.slice_drop_mm - 3.75, ...
    category_count * 3 * options.font_size_pt / 8);
if isempty(options.figure_mm)
    options.figure_mm = [minimum_width, max(minimum_height, bar_height + 10.8)];
end
validateattributes(options.figure_mm, {'numeric'}, {'real', 'finite', 'positive', 'size', [1, 2]});
assert(all(options.figure_mm + 1e-10 >= [minimum_width, minimum_height]), ...
    'BifurcationSlices:LayoutTooSmall', ...
    'The figure must be at least %.3g-by-%.3g mm for this layout; adjust slice geometry or margins.', minimum_width, minimum_height);
if isempty(options.colorbar_mm)
    options.colorbar_mm = [minimum_width - options.margins_mm(3) + 3, ...
        (options.figure_mm(2) - bar_height) / 2 - 1.35, 1.65, bar_height];
end
if isempty(options.x_limits)
    options.x_limits = [min(arrayfun(@(s) s.x(1), slices)), max(arrayfun(@(s) s.x(end), slices))];
end
if isempty(options.y_limits)
    options.y_limits = [min(arrayfun(@(s) s.y(1), slices)), max(arrayfun(@(s) s.y(end), slices))];
end
validateattributes(options.x_limits, {'numeric'}, {'real', 'finite', 'size', [1, 2], 'increasing'});
validateattributes(options.y_limits, {'numeric'}, {'real', 'finite', 'size', [1, 2], 'increasing'});
for k = 1:count
    assert(slices(k).x(1) >= options.x_limits(1) && slices(k).x(end) <= options.x_limits(2) && ...
        slices(k).y(1) >= options.y_limits(1) && slices(k).y(end) <= options.y_limits(2), ...
        'BifurcationSlices:ClippedData', 'Configured axis limits would clip slice %d.', k);
end
if isempty(options.x_ticks)
    options.x_ticks = linspace(options.x_limits(1), options.x_limits(2), 5);
end
if isempty(options.y_ticks)
    options.y_ticks = linspace(options.y_limits(1), options.y_limits(2), 5);
end
if isempty(options.panel_labels)
    options.panel_labels = arrayfun(@panel_label, 1:count, 'UniformOutput', false);
else
    options.panel_labels = cellstr(string(options.panel_labels));
end
end

function validate_options(options, count, category_count)
assert(any(strcmpi(listfonts, options.font_name)), 'BifurcationSlices:MissingFont', ...
    'The requested font, %s, is not installed.', options.font_name);
validateattributes(options.colorbar_mm, {'numeric'}, {'real', 'finite', 'size', [1, 4]});
b = options.colorbar_mm;
assert(all(b(1:2) >= 0) && all(b(3:4) > 0) && all(b(1:2) + b(3:4) <= options.figure_mm), ...
    'BifurcationSlices:ColorbarOutsideFigure', 'Colorbar position must lie within the figure.');
assert(b(4) / category_count >= options.font_size_pt * 25.4 / 72, ...
    'BifurcationSlices:ColorbarTooShort', 'Increase colorbar height to provide at least one font point-height per category.');
assert(numel(options.panel_labels) == count, 'BifurcationSlices:PanelLabels', ...
    'Supply one panel label per slice.');
validateattributes(options.x_ticks, {'numeric'}, {'real', 'finite', 'vector', 'increasing'});
validateattributes(options.y_ticks, {'numeric'}, {'real', 'finite', 'vector', 'increasing'});
assert(all(options.x_ticks >= options.x_limits(1) & options.x_ticks <= options.x_limits(2)) && ...
    all(options.y_ticks >= options.y_limits(1) & options.y_ticks <= options.y_limits(2)), ...
    'BifurcationSlices:InvalidTicks', 'Ticks must lie within their axis limits.');
names = {'x_label_offset_mm', 'y_label_offset_mm', 'x_tick_offset_mm', ...
    'y_tick_offset_mm', 'title_offset_mm', 'tick_length_mm', 'line_width_pt'};
for k = 1:numel(names)
    validateattributes(options.(names{k}), {'numeric'}, {'real', 'scalar', 'finite', 'nonnegative'});
end
validateattributes(options.border_color, {'numeric'}, {'size', [1, 3], 'real', 'finite', '>=', 0, '<=', 1});
validateattributes(options.resolution, {'numeric'}, {'scalar', 'integer', 'positive', 'finite'});
if ~isempty(options.preview_width_px)
    validateattributes(options.preview_width_px, {'numeric'}, {'scalar', 'integer', 'positive', 'finite'});
end
assert(ismember(string(options.visible), ["on", "off"]), ...
    'BifurcationSlices:InvalidVisibility', 'Visible must be on or off.');
assert(all(ismember(string(options.formats), ["fig", "png"])), ...
    'BifurcationSlices:UnsupportedFormat', 'Supported export formats are fig and png.');
assert(ismember(string(options.title_interpreter), ["none", "tex"]) && ...
    ismember(string(options.label_interpreter), ["none", "tex"]), ...
    'BifurcationSlices:InvalidInterpreter', 'Use none or tex to retain the requested font.');
end

function label = panel_label(index)
letters = '';
while index > 0
    letters = [char('a' + mod(index - 1, 26)), letters]; %#ok<AGROW>
    index = floor((index - 1) / 26);
end
label = ['(', letters, ')'];
end

function value = text_scalar(value, field)
assert((ischar(value) && (isrow(value) || isempty(value))) || (isstring(value) && isscalar(value) && ~ismissing(value)), ...
    'BifurcationSlices:InvalidText', '%s must be a text scalar.', field);
value = char(value);
end

function edges = sample_edges(samples)
samples = samples(:).';
edges = [samples(1), samples(1:end-1) + diff(samples) / 2, samples(end)];
end

function [x, y] = coordinates(a, f, origin, options)
u = (a - options.x_limits(1)) / diff(options.x_limits);
v = (f - options.y_limits(1)) / diff(options.y_limits);
x = origin(1) + options.slice_width_mm * u;
y = origin(2) + options.slice_height_mm * v - options.slice_drop_mm * u;
end

function draw_labels(ax, origin, index, row_start, title, options)
a = options.x_limits;
f = options.y_limits;
[x, y] = coordinates(a([1, 2, 2, 1, 1]), f([1, 1, 2, 2, 1]), origin, options);
plot(ax, x, y, 'Color', options.border_color, 'LineWidth', options.line_width_pt, ...
    'Tag', sprintf('slice_border_%d', index));
angle = -atan2d(options.slice_drop_mm, options.slice_width_mm);
for tick = options.x_ticks(:).'
    [x, y] = coordinates(tick, f(1), origin, options);
    plot(ax, [x, x], [y, y - options.tick_length_mm], 'k-', 'LineWidth', options.line_width_pt);
    slice_text(ax, x, y - options.x_tick_offset_mm, sprintf('%g', tick), options, ...
        'VerticalAlignment', 'top', 'Rotation', angle, 'Tag', sprintf('x_tick_%d', index));
end
[x, y] = coordinates(mean(a), f(1), origin, options);
slice_text(ax, x, y - options.x_label_offset_mm, options.x_label, options, ...
    'Interpreter', options.label_interpreter, 'Rotation', angle, 'Tag', sprintf('x_label_%d', index));
[x, y] = coordinates(mean(a), f(2), origin, options);
label = strtrim([options.panel_labels{index}, ' ', title]);
slice_text(ax, x, y + options.title_offset_mm, label, options, ...
    'Interpreter', options.title_interpreter, 'Rotation', angle, 'Tag', sprintf('panel_label_%d', index));
if row_start
    for tick = options.y_ticks(:).'
        [x, y] = coordinates(a(1), tick, origin, options);
        plot(ax, [x - options.tick_length_mm, x], [y, y], 'k-', 'LineWidth', options.line_width_pt);
        slice_text(ax, x - options.y_tick_offset_mm, y, sprintf('%g', tick), options, ...
            'HorizontalAlignment', 'right', 'Tag', sprintf('y_tick_%d', index));
    end
    [x, y] = coordinates(a(1), mean(f), origin, options);
    slice_text(ax, x - options.y_label_offset_mm, y, options.y_label, options, ...
        'Interpreter', options.label_interpreter, 'Rotation', 90, 'Tag', sprintf('y_label_%d', index));
end
end

function h = slice_text(ax, x, y, label, options, varargin)
h = text(ax, x, y, label, 'FontName', options.font_name, 'FontUnits', 'points', ...
    'FontSize', options.font_size_pt, 'FontWeight', 'normal', 'Color', 'k', ...
    'Interpreter', 'none', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'Clipping', 'off', varargin{:});
end

function check_text_bounds(ax, cb, labels, options)
for h = findall(ax, 'Type', 'text').'
    if isempty(h.String)
        continue;
    end
    e = h.Extent;
    assert(e(1) >= 0 && e(2) >= 0 && e(1) + e(3) <= options.figure_mm(1) && ...
        e(2) + e(4) <= options.figure_mm(2), 'BifurcationSlices:TextOutsideFigure', ...
        'Text %s lies outside the figure; adjust margins or label offsets.', h.Tag);
end
% Colorbar tick labels are not regular Text children. Measure their strings
% in the same font and reserve a conservative gap after the bar.
probe = slice_text(ax, 0, 0, '', options, 'Visible', 'off', 'HorizontalAlignment', 'left');
cleanup = onCleanup(@() delete(probe));
widest = 0;
for k = 1:numel(labels)
    probe.String = labels{k};
    widest = max(widest, probe.Extent(3));
end
right_edge = (cb.Position(1) + cb.Position(3)) * options.figure_mm(1);
assert(right_edge + 1 + widest <= options.figure_mm(1), ...
    'BifurcationSlices:ColorbarLabelsOutsideFigure', ...
    'Colorbar labels need more room; increase the right margin or move the colorbar left.');
end

function export_outputs(fig, options)
prefix = text_scalar(options.output_prefix, 'output_prefix');
if isempty(prefix)
    return;
end
parent = fileparts(prefix);
if ~isempty(parent) && ~isfolder(parent)
    mkdir(parent);
end
fig.PaperUnits = 'centimeters';
fig.PaperSize = options.figure_mm / 10;
fig.PaperPosition = [0, 0, options.figure_mm / 10];
fig.PaperPositionMode = 'manual';
if any(strcmp(options.formats, 'png'))
    exportgraphics(fig, [prefix, '.png'], 'Resolution', options.resolution, ...
        'Units', 'centimeters', 'Width', options.figure_mm(1) / 10, ...
        'Height', options.figure_mm(2) / 10, 'Padding', 'figure', 'BackgroundColor', 'white');
end
if any(strcmp(options.formats, 'fig'))
    savefig(fig, [prefix, '.fig']);
end
if ~isempty(options.preview_width_px)
    width = options.preview_width_px;
    % Keep the physical canvas unchanged so text and colorbar layout match
    % the main export. MATLAB requires an integer resolution, so the target
    % preview width can differ slightly after DPI and pixel rounding.
    exportgraphics(fig, [prefix, '_preview.png'], ...
        'Resolution', max(1, round(width * 25.4 / options.figure_mm(1))), ...
        'Units', 'centimeters', 'Width', options.figure_mm(1) / 10, ...
        'Height', options.figure_mm(2) / 10, ...
        'Padding', 'figure', 'BackgroundColor', 'white');
end
fprintf('Output prefix: %s\n', prefix);
end
