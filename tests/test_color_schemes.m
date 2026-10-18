function tests = test_color_schemes
%TEST_COLOR_SCHEMES Check shared palettes, validation, and slice integration.
%   Fixture JSON, synthetic MAT inputs, and figures stay in a temporary
%   directory outside the repository. Loader checks do not require a font.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
repo_root = fileparts(fileparts(mfilename('fullpath')));
testCase.TestData.original_path = path;
testCase.TestData.scripts_dir = fullfile(repo_root, 'scientific-plotting', 'scripts');
testCase.TestData.output_dir = tempname(tempdir);
mkdir(testCase.TestData.output_dir);
addpath(testCase.TestData.scripts_dir, '-begin');
clear load_color_scheme;
fprintf('Color-scheme verification outputs: %s\n', testCase.TestData.output_dir);
end

function teardownOnce(testCase)
restore_loader(testCase.TestData.original_path);
end

function testDefaultAndExactSailRainColors(testCase)
scheme = load_color_scheme();
verifyEqual(testCase, scheme, load_color_scheme('sailrain'));
verifyEqual(testCase, scheme, load_color_scheme("sailrain"));
verifyEqual(testCase, scheme.id, 'sailrain');
verifyEqual(testCase, scheme.display_name, 'SailRain');
verifyEqual(testCase, scheme.author, 'SailRain');
verifyNotEmpty(testCase, scheme.source_note);
verifyEqual(testCase, scheme.categorical_colors, expected_categorical_colors());
verifyEqual(testCase, scheme.waveform_colors, [1, 0, 0; 0, 0, 1; 0, 0, 0]);
verifyEqual(testCase, scheme.phase_trajectory_color, [0, 0.75, 0.75]);
verifyEqual(testCase, scheme.categorical_source_labels, ...
    {'RS', 'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8', 'P9', 'MP', 'CH', 'UB'});
end

function testIndependentOfWorkingDirectory(testCase)
expected = load_color_scheme();
previous_dir = pwd;
cleanup = onCleanup(@() cd(previous_dir)); %#ok<NASGU>
cd(testCase.TestData.output_dir);
verifyEqual(testCase, load_color_scheme(), expected);
verifyEqual(testCase, load_color_scheme('sailrain'), expected);
end

function testInvalidAndUnknownIds(testCase)
invalid_ids = {[], 7, '', "", ["sailrain", "other"], '../sailrain', ...
    'SailRain', 'sailrain.json', 'two schemes'};
for k = 1:numel(invalid_ids)
    verifyError(testCase, @() load_color_scheme(invalid_ids{k}), 'ColorScheme:InvalidId');
end
verifyError(testCase, @() load_color_scheme('missing_scheme'), 'ColorScheme:UnknownScheme');
end

function testMalformedJsonAndMetadata(testCase)
verifyError(testCase, @() load_fixture(testCase, '{not valid JSON'), 'ColorScheme:InvalidJson');
scheme = load_color_scheme();
required = {'id', 'display_name', 'author', 'source_note'};
for k = 1:numel(required)
    bad = rmfield(scheme, required{k});
    verifyError(testCase, @() load_fixture(testCase, jsonencode(bad)), 'ColorScheme:InvalidScheme');
    bad = scheme;
    bad.(required{k}) = '';
    verifyError(testCase, @() load_fixture(testCase, jsonencode(bad)), 'ColorScheme:InvalidScheme');
end
bad = scheme;
bad.id = 'different_id';
verifyError(testCase, @() load_fixture(testCase, jsonencode(bad)), 'ColorScheme:InvalidScheme');
end

function testInvalidRgbData(testCase)
scheme = load_color_scheme();
fields = {'categorical_colors', 'waveform_colors', 'phase_trajectory_color'};
for k = 1:numel(fields)
    bad = rmfield(scheme, fields{k});
    verifyError(testCase, @() load_fixture(testCase, jsonencode(bad)), 'ColorScheme:InvalidColors');
    invalid_colors = {[], [0, 1], zeros(2, 2), [0, 0, 2], [0, -0.1, 0], ...
        [0, NaN, 0], [0, Inf, 0], 'cyan'};
    for j = 1:numel(invalid_colors)
        bad = scheme;
        bad.(fields{k}) = invalid_colors{j};
        verifyError(testCase, @() load_fixture(testCase, jsonencode(bad)), 'ColorScheme:InvalidColors');
    end
end
bad = scheme;
bad.phase_trajectory_color = [0, 0.75, 0.75; 1, 0, 0];
verifyError(testCase, @() load_fixture(testCase, jsonencode(bad)), 'ColorScheme:InvalidColors');
end

function testAdditionalSchemeAndSingleRgbRows(testCase)
scheme = load_color_scheme();
scheme.id = 'future_author';
scheme.display_name = 'Synthetic fixture';
scheme.author = 'Synthetic author';
scheme.categorical_colors = [0.1, 0.2, 0.3];
scheme.waveform_colors = [0.4, 0.5, 0.6];
scheme = rmfield(scheme, 'categorical_source_labels');
actual = load_fixture(testCase, jsonencode(scheme), 'future_author');
verifyEqual(testCase, actual.id, 'future_author');
verifyEqual(testCase, actual.categorical_colors, [0.1, 0.2, 0.3]);
verifyEqual(testCase, actual.waveform_colors, [0.4, 0.5, 0.6]);
verifyEqual(testCase, actual.phase_trajectory_color, [0, 0.75, 0.75]);
end

function testExplicitRgbAndDemoPalette(testCase)
assert(any(strcmpi(listfonts, 'Times New Roman')), ...
    'ColorSchemeTests:MissingFont', 'Install Times New Roman before running figure checks.');
% Explicit RGB remains independent of the selected scheme and numeric codes.
categories.codes = [42, -4, 7];
categories.labels = {'Zeta', 'Alpha', 'Beta'};
categories.colors = [0.2, 0.4, 0.8; 0.95, 0.45, 0.1; 0.25, 0.65, 0.3];
slice = struct('x', [0, 0.2, 1], 'y', [10, 50], ...
    'S', [42, -4, 7; 7, 42, -4], 'metadata', struct('synthetic', true));
options = struct('visible', 'off', 'x_limits', [0, 1], 'y_limits', [10, 50], ...
    'x_ticks', [0, 0.5, 1], 'y_ticks', [10, 30, 50], ...
    'x_label', 'x, a.u.', 'y_label', 'y, a.u.');
[fig, ax, cb] = render_bifurcation_slices(slice, categories, options);
cleanup = onCleanup(@() close(fig));
verifyEqual(testCase, colormap(ax), categories.colors);
verifyEqual(testCase, fig.UserData.category_codes, categories.codes);
verifyEqual(testCase, cb.TickLabels(:), categories.labels(:));
surface = findall(ax, 'Type', 'surface');
verifyEqual(testCase, surface.CData(1:2, 1:3), [1, 2, 3; 3, 1, 2]);
clear cleanup;

output_dir = fullfile(testCase.TestData.output_dir, 'demo_palette');
[fig, ax, ~] = demo_bifurcation_slices(3, output_dir);
cleanup = onCleanup(@() close(fig));
scheme = load_color_scheme();
verifyEqual(testCase, colormap(ax), scheme.categorical_colors([1, 2, 12], :));
clear cleanup;
reopened = openfig(fullfile(output_dir, 'demo_3_slices.fig'), 'invisible');
cleanup = onCleanup(@() close(reopened)); %#ok<NASGU>
ax = findall(reopened, 'Type', 'axes');
verifyEqual(testCase, numel(ax), 1);
verifyEqual(testCase, colormap(ax), scheme.categorical_colors([1, 2, 12], :));
end

function scheme = load_fixture(testCase, json_text, scheme_id)
% Copy the loader to isolate invalid assets without touching the installation.
if nargin < 3
    scheme_id = 'sailrain';
end
fixture_root = tempname(testCase.TestData.output_dir);
scripts_dir = fullfile(fixture_root, 'scripts');
asset_dir = fullfile(fixture_root, 'assets', 'color-schemes');
mkdir(scripts_dir);
mkdir(asset_dir);
copyfile(fullfile(testCase.TestData.scripts_dir, 'load_color_scheme.m'), scripts_dir);
filename = fullfile(asset_dir, [scheme_id, '.json']);
file_id = fopen(filename, 'w');
assert(file_id ~= -1, 'ColorSchemeTests:FixtureWrite', 'Unable to write fixture JSON.');
file_cleanup = onCleanup(@() fclose(file_id));
fprintf(file_id, '%s', json_text);
clear file_cleanup;
previous_path = path;
cleanup = onCleanup(@() restore_loader(previous_path)); %#ok<NASGU>
addpath(scripts_dir, '-begin');
clear load_color_scheme;
scheme = load_color_scheme(scheme_id);
end

function restore_loader(previous_path)
path(previous_path);
clear load_color_scheme;
end

function colors = expected_categorical_colors()
% The user's original 13-row sequence is an independent regression oracle.
colors = [0.45, 0.45, 0.45; 0, 1, 1; 1, 0.70, 0.70; ...
    0.47, 0.86, 0.19; 0.42, 0.20, 0.47; 0.93, 0.55, 0.13; ...
    0.45, 0.75, 0.93; 0.99, 0.87, 0.07; 0.05, 0.55, 0.55; ...
    0.20, 0.20, 0.75; 0.64, 0.08, 0.18; 1, 0.10, 1; 0, 0, 0];
end
