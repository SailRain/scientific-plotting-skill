function [fig, ax, cb] = demo_bifurcation_slices(slice_count, output_dir)
%DEMO_BIFURCATION_SLICES Demonstrate MAT adaptation and flexible slice layouts.
%   DEMO_BIFURCATION_SLICES() draws five synthetic category slices.
%   DEMO_BIFURCATION_SLICES(N) draws N slices in at most three columns.
%   DEMO_BIFURCATION_SLICES(N, OUTPUT_DIR) selects the output folder.
%   The default output folder is a new unique directory under TEMPDIR,
%   independent of the current working directory. Its path is printed.
%   These small MAT files demonstrate plotting only. They are not simulation
%   results, measured data, or evidence of any dynamical behavior.

if nargin < 1
    slice_count = 5;
end
validateattributes(slice_count, {'numeric'}, ...
    {'scalar', 'real', 'finite', 'integer', 'positive'}, mfilename, 'slice_count');

%% Example configuration: replace these settings for an actual data source.
if nargin < 2 || isempty(output_dir)
    output_dir = tempname(tempdir);
end
categories.codes = [-4, 7, 42];
categories.labels = {'Zone A', 'Zone B', 'Zone C'};
categories.colors = [0.45, 0.45, 0.45; 0.00, 1.00, 1.00; 1.00, 0.10, 1.00];
options.columns = min(3, slice_count);
options.x_limits = [0, 1];
options.y_limits = [10, 50];
options.x_ticks = [0, 0.5, 1];
options.y_ticks = [10, 30, 50];
options.x_label = 'x, a.u.';
options.y_label = 'y, a.u.';
options.font_name = 'Times New Roman';
options.font_size_pt = 8;
options.output_prefix = fullfile(output_dir, sprintf('demo_%d_slices', slice_count));
options.formats = {'fig', 'png'};
options.resolution = 600;
options.preview_width_px = 1000;

%% Save and reload small files with an explicit source-field mapping.
if ~isfolder(output_dir)
    mkdir(output_dir);
end
slices = repmat(struct('x', [], 'y', [], 'S', [], 'title', '', ...
    'source_file', '', 'metadata', struct()), 1, slice_count);
for k = 1:slice_count
    % Different rectangular, nonuniform grids make orientation observable.
    x_values = linspace(0, 1, 12 + k) .^ (1 + 0.07 * k);
    y_values = 10 + 40 * linspace(0, 1, 8 + k) .^ 1.3;
    [column_index, row_index] = meshgrid(1:numel(x_values), 1:numel(y_values));
    display_index = 1 + mod(floor((column_index - 1) / 3) + ...
        floor((row_index - 1) / 2) + k, numel(categories.codes));
    class_codes = reshape(categories.codes(display_index(:)), size(display_index));
    example_metadata = struct('synthetic', true, 'slice_index', k, ...
        'description', 'Synthetic layout example; not a dynamical simulation.', ...
        'matrix_orientation', 'Rows follow y_values; columns follow x_values.');
    source_file = fullfile(output_dir, sprintf('synthetic_slice_%02d.mat', k));
    save(source_file, 'x_values', 'y_values', 'class_codes', 'example_metadata');

    saved = load(source_file, 'x_values', 'y_values', 'class_codes', 'example_metadata');
    slices(k).x = saved.x_values;
    slices(k).y = saved.y_values;
    slices(k).S = saved.class_codes;
    slices(k).title = sprintf('Synthetic %d', k);
    slices(k).source_file = source_file;
    slices(k).metadata = saved.example_metadata;
end

[fig, ax, cb] = render_bifurcation_slices(slices, categories, options);
fprintf('Synthetic layout example: %d slices; no simulation was performed.\n', slice_count);
fprintf('Example MAT files and exported figures: %s\n', output_dir);
end
