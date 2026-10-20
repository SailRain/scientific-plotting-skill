function tests = test_bifurcation_slices
%TEST_BIFURCATION_SLICES Check data fidelity, export backends, and demo paths.
%   Run with runtests(fullfile(repo_root, 'tests')). Outputs are written to
%   a new temporary directory, whose path is printed for visual inspection.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
repo_root = fileparts(fileparts(mfilename('fullpath')));
testCase.TestData.original_path = path;
testCase.TestData.skill_root = fullfile(repo_root, 'scientific-plotting');
testCase.TestData.output_dir = tempname(tempdir);
mkdir(testCase.TestData.output_dir);
addpath(fullfile(testCase.TestData.skill_root, 'scripts'), '-begin');
assert(any(strcmpi(listfonts, 'Times New Roman')), ...
    'PlottingTests:MissingFont', 'Install Times New Roman before running figure checks.');
fprintf('Plotting verification outputs: %s\n', testCase.TestData.output_dir);
end

function teardownOnce(testCase)
path(testCase.TestData.original_path);
end

function testAutomaticBackend(testCase)
[slices, categories, options] = fixture(1);
options.output_prefix = fullfile(testCase.TestData.output_dir, 'automatic');
[fig, ax, cb] = render_bifurcation_slices(slices, categories, options);
cleanup = onCleanup(@() close(fig)); %#ok<NASGU>
if verLessThan('matlab', '25.1')
    expected = 'print';
else
    expected = 'exportgraphics';
end
verifyEqual(testCase, fig.UserData.export_backend, expected);
verify_data(testCase, fig, ax, cb, slices, categories);
verify_png(testCase, [options.output_prefix, '.png'], fig.UserData.layout, 600);
end

function testBothBackendsAndLayouts(testCase)
backends = {'print', 'exportgraphics'};
for b = 1:numel(backends)
    for count = [1, 3, 5]
        [slices, categories, options] = fixture(count);
        options.export_backend = backends{b};
        options.preview_width_px = 1000;
        options.output_prefix = fullfile(testCase.TestData.output_dir, ...
            sprintf('%s_%d', backends{b}, count));
        if strcmp(backends{b}, 'exportgraphics') && verLessThan('matlab', '25.1')
            verifyError(testCase, @() render_bifurcation_slices(slices, categories, options), ...
                'BifurcationSlices:UnsupportedExportBackend');
            continue;
        end
        [fig, ax, cb] = render_bifurcation_slices(slices, categories, options);
        cleanup = onCleanup(@() close(fig));
        verifyEqual(testCase, fig.UserData.export_backend, backends{b});
        verify_data(testCase, fig, ax, cb, slices, categories);
        layout = fig.UserData.layout;
        verify_png(testCase, [options.output_prefix, '.png'], layout, 600);
        verify_raster_cells(testCase, [options.output_prefix, '.png'], fig, slices, categories);
        preview_dpi = max(1, round(1000 * 25.4 / layout.figure_mm(1)));
        verify_png(testCase, [options.output_prefix, '_preview.png'], layout, preview_dpi);
        reopened = openfig([options.output_prefix, '.fig'], 'invisible');
        reopen_cleanup = onCleanup(@() close(reopened));
        verifyEqual(testCase, reopened.UserData.export_backend, backends{b});
        surfaces = findall(reopened, 'Type', 'surface');
        verifyEqual(testCase, numel(surfaces), count);
        surfaces(1).Visible = 'off';
        verifyEqual(testCase, char(surfaces(1).Visible), 'off');
        colorbars = findall(reopened, 'Type', 'colorbar');
        verifyEqual(testCase, numel(colorbars), 1);
        colorbars(1).Visible = 'off';
        verifyEqual(testCase, char(colorbars(1).Visible), 'off');
        clear reopen_cleanup cleanup;
    end
end
end

function testFigureOnlyWithoutOutput(testCase)
[slices, categories, options] = fixture(1);
before = dir(testCase.TestData.output_dir);
[fig, ax, cb] = render_bifurcation_slices(slices, categories, options);
cleanup = onCleanup(@() close(fig)); %#ok<NASGU>
verify_data(testCase, fig, ax, cb, slices, categories);
verifyFalse(testCase, isfield(fig.UserData, 'export_backend'));
after = dir(testCase.TestData.output_dir);
verifyEqual(testCase, {after.name}, {before.name});
end

function testFigOnlyAndPreviewOnly(testCase)
[slices, categories, options] = fixture(1);
options.formats = {'fig'};
options.export_backend = 'exportgraphics';
options.output_prefix = fullfile(testCase.TestData.output_dir, 'fig_only');
[fig, ~, ~] = render_bifurcation_slices(slices, categories, options);
cleanup = onCleanup(@() close(fig));
verifyTrue(testCase, isfile([options.output_prefix, '.fig']));
verifyFalse(testCase, isfile([options.output_prefix, '.png']));
verifyFalse(testCase, isfield(fig.UserData, 'export_backend'));
clear cleanup;
options.export_backend = 'print';
options.preview_width_px = 800;
options.output_prefix = fullfile(testCase.TestData.output_dir, 'fig_with_preview');
[fig, ~, ~] = render_bifurcation_slices(slices, categories, options);
cleanup = onCleanup(@() close(fig)); %#ok<NASGU>
verifyTrue(testCase, isfile([options.output_prefix, '.fig']));
verifyFalse(testCase, isfile([options.output_prefix, '.png']));
verifyTrue(testCase, isfile([options.output_prefix, '_preview.png']));
verifyEqual(testCase, fig.UserData.export_backend, 'print');
end

function testMathMinusNumericTicks(testCase)
[slices, categories, options] = fixture(1);
slices.x = -2 + 5 * slices.x;
slices.y = -40 + 90 * (slices.y - 10) / 40;
options.x_limits = [-2, 3];
options.y_limits = [-40, 50];
options.x_ticks = [-2, 0, 3];
options.y_ticks = [-40, 0, 50];
original_slices = slices;
original_categories = categories;
[fig, ax, cb] = render_bifurcation_slices(slices, categories, options);
cleanup = onCleanup(@() close(fig)); %#ok<NASGU>
minus = char(8722);
verify_tick_text(testCase, ax, 'x_tick_1', {[minus, '2'], '0', '3'});
verify_tick_text(testCase, ax, 'y_tick_1', {[minus, '40'], '0', '50'});
verifyEqual(testCase, fig.UserData.layout.x_ticks, options.x_ticks);
verifyEqual(testCase, fig.UserData.layout.y_ticks, options.y_ticks);
verifyEqual(testCase, fig.UserData.layout.x_limits, options.x_limits);
verifyEqual(testCase, fig.UserData.layout.y_limits, options.y_limits);
verifyEqual(testCase, slices, original_slices);
verifyEqual(testCase, categories, original_categories);
verify_data(testCase, fig, ax, cb, slices, categories);
end

function testPreparedMathTextAndScientificTicksBothBackends(testCase)
minus = char(8722);
backends = {'print', 'exportgraphics'};
for b = 1:numel(backends)
    if strcmp(backends{b}, 'exportgraphics') && verLessThan('matlab', '25.1')
        continue;
    end
    [slices, categories, options] = fixture(1);
    slices.x = (-1 + 2 * slices.x) * 1e-5;
    slices.y = (-1 + 2 * (slices.y - 10) / 40) * 1e-6;
    slices.title = ['Run-1: 10^{', minus, '3}'];
    slices.source_file = 'synthetic_Run-1.mat';
    slices.metadata.source_labels = {'negative-4', 'time-response', 'x-y', 'Run-1'};
    categories.labels = {[minus, '4'], 'time-response', ['x', minus, 'y'], 'Run-1'};
    options.x_limits = [-1e-5, 1e-5];
    options.y_limits = [-1e-6, 1e-6];
    options.x_ticks = [-1e-5, 0, 1e-5];
    options.y_ticks = [-1e-6, 0, 1e-6];
    options.x_label = ['r, s^{', minus, '1}'];
    options.y_label = ['x', minus, 'y'];
    options.title_interpreter = 'tex';
    options.figure_name = 'time-response Run-1';
    options.slice_width_mm = 60;
    options.slice_height_mm = 45;
    options.margins_mm = [18, 12, 34, 10];
    options.export_backend = backends{b};
    options.output_prefix = fullfile(testCase.TestData.output_dir, ...
        ['math_minus_', backends{b}]);
    original_slices = slices;
    original_categories = categories;
    [fig, ax, cb] = render_bifurcation_slices(slices, categories, options);
    cleanup = onCleanup(@() close(fig));
    verify_tick_text(testCase, ax, 'x_tick_1', ...
        {[minus, '1e', minus, '05'], '0', ['1e', minus, '05']});
    verify_tick_text(testCase, ax, 'y_tick_1', ...
        {[minus, '1e', minus, '06'], '0', ['1e', minus, '06']});
    verify_prepared_text(testCase, fig, ax, cb, slices, categories, options);
    verifyEqual(testCase, slices, original_slices);
    verifyEqual(testCase, categories, original_categories);
    verify_data(testCase, fig, ax, cb, slices, categories);
    verify_png(testCase, [options.output_prefix, '.png'], fig.UserData.layout, 600);
    verify_raster_cells(testCase, [options.output_prefix, '.png'], fig, slices, categories);
    reopened = openfig([options.output_prefix, '.fig'], 'invisible');
    reopen_cleanup = onCleanup(@() close(reopened));
    reopened_ax = findall(reopened, 'Type', 'axes');
    reopened_cb = findall(reopened, 'Type', 'colorbar');
    verify_tick_text(testCase, reopened_ax, 'x_tick_1', ...
        {[minus, '1e', minus, '05'], '0', ['1e', minus, '05']});
    verify_prepared_text(testCase, reopened, reopened_ax, reopened_cb, ...
        slices, categories, options);
    verify_data(testCase, reopened, reopened_ax, reopened_cb, slices, categories);
    label = findobj(reopened_ax, 'Tag', 'x_label_1');
    label.String = ['r, s^{', minus, '2}'];
    verifyEqual(testCase, label.String, ['r, s^{', minus, '2}']);
    verifyEqual(testCase, reopened.UserData.layout.x_ticks, options.x_ticks);
    verifyEqual(testCase, reopened.UserData.layout.y_ticks, options.y_ticks);
    verifyEqual(testCase, reopened.UserData.layout.x_limits, options.x_limits);
    verifyEqual(testCase, reopened.UserData.layout.y_limits, options.y_limits);
    clear reopen_cleanup cleanup;
end
end

function testInputErrors(testCase)
[slices, categories, options] = fixture(1);
bad = slices;
bad.S(1) = 999;
verifyError(testCase, @() render_bifurcation_slices(bad, categories, options), ...
    'BifurcationSlices:InvalidCategory');
bad.S = slices.S.';
verifyError(testCase, @() render_bifurcation_slices(bad, categories, options), ...
    'BifurcationSlices:InvalidGrid');
bad = slices;
bad.S(1) = NaN;
verifyError(testCase, @() render_bifurcation_slices(bad, categories, options), ...
    'BifurcationSlices:InvalidCategory');
options.export_backend = 'invalid';
verifyError(testCase, @() render_bifurcation_slices(slices, categories, options), ...
    'BifurcationSlices:InvalidExportBackend');
options.export_backend = 'auto';
options.x_limits = [0.1, 1];
verifyError(testCase, @() render_bifurcation_slices(slices, categories, options), ...
    'BifurcationSlices:ClippedData');
options.x_limits = [0, 1];
options.font_name = 'A deliberately unavailable font for verification';
verifyError(testCase, @() render_bifurcation_slices(slices, categories, options), ...
    'BifurcationSlices:MissingFont');
end

function testDemoDefaultOutsideSkill(testCase)
previous_dir = pwd;
directory_cleanup = onCleanup(@() cd(previous_dir)); %#ok<NASGU>
cd(testCase.TestData.skill_root);
[fig, ~, ~] = demo_bifurcation_slices();
cleanup = onCleanup(@() close(fig));
output_dir = fileparts(fig.UserData.source_files{1});
verifyTrue(testCase, startsWith(output_dir, tempdir));
verifyFalse(testCase, startsWith(output_dir, [testCase.TestData.skill_root, filesep]));
verifyEqual(testCase, numel(dir(fullfile(output_dir, 'synthetic_slice_*.mat'))), 5);
clear cleanup;
[fig, ~, ~] = demo_bifurcation_slices(1, []);
cleanup = onCleanup(@() close(fig)); %#ok<NASGU>
verifyNotEqual(testCase, fileparts(fig.UserData.source_files{1}), output_dir);
end

function testDemoExplicitDirectory(testCase)
output_dir = fullfile(testCase.TestData.output_dir, 'explicit_demo');
[fig, ~, ~] = demo_bifurcation_slices(3, output_dir);
cleanup = onCleanup(@() close(fig)); %#ok<NASGU>
verifyEqual(testCase, fileparts(fig.UserData.source_files{1}), output_dir);
verifyEqual(testCase, numel(dir(fullfile(output_dir, 'synthetic_slice_*.mat'))), 3);
verifyTrue(testCase, isfile(fullfile(output_dir, 'demo_3_slices.fig')));
verifyTrue(testCase, isfile(fullfile(output_dir, 'demo_3_slices.png')));
end

function [slices, categories, options] = fixture(count)
categories.codes = [-4, 7, 42, 100];
categories.labels = {'Zone A', 'Zone B', 'Zone C', 'Zone D'};
categories.colors = [0.45, 0.45, 0.45; 0, 1, 1; 1, 0.1, 1; 0.1, 0.25, 0.8];
slices = repmat(struct('x', [], 'y', [], 'S', [], 'metadata', struct('synthetic', true)), 1, count);
for k = 1:count
    slices(k).x = linspace(0, 1, 5 + k) .^ 1.3;
    slices(k).y = 10 + 40 * linspace(0, 1, 3 + k) .^ 1.2;
    [x_index, y_index] = meshgrid(1:numel(slices(k).x), 1:numel(slices(k).y));
    indices = 1 + mod(x_index + 2 * y_index + k, numel(categories.codes));
    slices(k).S = reshape(categories.codes(indices(:)), size(indices));
end
options = struct('visible', 'off', 'x_limits', [0, 1], 'y_limits', [10, 50], ...
    'x_ticks', [0, 0.5, 1], 'y_ticks', [10, 30, 50], ...
    'x_label', 'x, a.u.', 'y_label', 'y, a.u.');
end

function verify_data(testCase, fig, ax, cb, slices, categories)
verifyEqual(testCase, ax.CLim, [0.5, numel(categories.codes) + 0.5]);
verifyEqual(testCase, cb.Ticks, 1:numel(categories.codes));
verifyEqual(testCase, string(cb.TickLabels), string(categories.labels(:)));
verifyEqual(testCase, cb.AxisLocation, 'out');
verifyEqual(testCase, colormap(ax), categories.colors);
for k = 1:numel(slices)
    surface_handle = findobj(ax, 'Tag', sprintf('bifurcation_slice_%d', k));
    [~, expected] = ismember(slices(k).S, categories.codes);
    [ny, nx] = size(expected);
    verifyEqual(testCase, size(surface_handle.XData), [ny + 1, nx + 1]);
    verifyEqual(testCase, surface_handle.CData(1:ny, 1:nx), expected);
    verifyEqual(testCase, surface_handle.UserData.sample_size, [ny, nx]);
    verifyEqual(testCase, surface_handle.FaceColor, 'flat');
end
verifyEqual(testCase, fig.Color, [1, 1, 1]);
end

function verify_tick_text(testCase, ax, tag, expected)
labels = findobj(ax, 'Tag', tag);
actual = string({labels.String});
verifyEqual(testCase, sort(actual(:)), sort(string(expected(:))));
verifyFalse(testCase, any(contains(actual, '-')));
verifyEqual(testCase, string({labels.Interpreter}), repmat("none", 1, numel(labels)));
end

function verify_prepared_text(testCase, fig, ax, cb, slices, categories, options)
x_label = findobj(ax, 'Tag', 'x_label_1');
y_label = findobj(ax, 'Tag', 'y_label_1');
title = findobj(ax, 'Tag', 'panel_label_1');
verifyEqual(testCase, x_label.String, options.x_label);
verifyEqual(testCase, y_label.String, options.y_label);
verifyEqual(testCase, title.String, ['(a) ', slices.title]);
verifyEqual(testCase, x_label.Interpreter, 'tex');
verifyEqual(testCase, title.Interpreter, 'tex');
verifyEqual(testCase, fig.Name, 'time-response Run-1');
verifyEqual(testCase, string(cb.TickLabels), string(categories.labels(:)));
verifyEqual(testCase, cb.TickLabelInterpreter, 'none');
surface_handle = findobj(ax, 'Tag', 'bifurcation_slice_1');
verifyEqual(testCase, surface_handle.UserData.source_labels, slices.metadata.source_labels);
verifyEqual(testCase, surface_handle.UserData.source_file, 'synthetic_Run-1.mat');
verifyEqual(testCase, surface_handle.UserData.category_codes, categories.codes);
end

function verify_png(testCase, filename, layout, dpi)
info = imfinfo(filename);
expected = round(layout.figure_mm / 25.4 * dpi);
verifyLessThanOrEqual(testCase, abs([info.Width, info.Height] - expected), [1, 1]);
verifyEqual(testCase, info.ResolutionUnit, 'meter');
actual_dpi = [info.XResolution, info.YResolution] * 0.0254;
verifyEqual(testCase, actual_dpi, [dpi, dpi], 'AbsTol', 0.05);
image = imread(filename);
verifyEqual(testCase, reshape(image(1, 1, :), 1, []), uint8([255, 255, 255]));
end

function verify_raster_cells(testCase, filename, fig, slices, categories)
image = imread(filename);
layout = fig.UserData.layout;
for k = 1:numel(slices)
    x = slices(k).x(:).';
    y = slices(k).y(:).';
    x_edges = [x(1), (x(1:end-1) + x(2:end)) / 2, x(end)];
    y_edges = [y(1), (y(1:end-1) + y(2:end)) / 2, y(end)];
    origin = fig.UserData.origins_mm(k, :);
    for column = unique([1, ceil(numel(x) / 2), numel(x)])
        for row = unique([1, ceil(numel(y) / 2), numel(y)])
            u = (mean(x_edges(column:column+1)) - layout.x_limits(1)) / diff(layout.x_limits);
            v = (mean(y_edges(row:row+1)) - layout.y_limits(1)) / diff(layout.y_limits);
            px = origin(1) + layout.slice_width_mm * u;
            py = origin(2) + layout.slice_height_mm * v - layout.slice_drop_mm * u;
            image_column = round(px / layout.figure_mm(1) * size(image, 2) + 0.5);
            image_row = round((layout.figure_mm(2) - py) / layout.figure_mm(2) * size(image, 1) + 0.5);
            [~, category] = ismember(slices(k).S(row, column), categories.codes);
            actual = reshape(double(image(image_row, image_column, :)), 1, []);
            verifyEqual(testCase, actual, 255 * categories.colors(category, :), 'AbsTol', 2);
        end
    end
end
end
