function scheme = load_color_scheme(scheme_id)
%LOAD_COLOR_SCHEME Load a shared plotting color scheme from bundled JSON.
%   SCHEME = LOAD_COLOR_SCHEME() loads the default SailRain scheme.
%   SCHEME = LOAD_COLOR_SCHEME(SCHEME_ID) selects a lowercase identifier,
%   such as 'sailrain'. The identifier must start with a letter and may
%   contain lowercase letters, digits, underscores, and hyphens.
%   Files are located relative to this function, not the working directory.
%   SCHEME contains id, display_name, author, source_note,
%   categorical_colors (N-by-3), waveform_colors (N-by-3), and
%   phase_trajectory_color (1-by-3). Optional categorical_source_labels
%   record provenance only and do not assign meanings to other datasets.
%   Colors are finite, real RGB values between 0 and 1. Task scripts select
%   colors and pass explicit RGB values to the plotting functions; this
%   loader does not allocate, interpolate, or cycle colors.
%   MATLAB R2020a or later is the compatibility target.

if nargin < 1
    scheme_id = 'sailrain';
end
if ~is_text_row(scheme_id)
    error('ColorScheme:InvalidId', ...
        'The color scheme identifier must be a nonempty character row or string scalar.');
end
scheme_id = char(scheme_id);
if isempty(regexp(scheme_id, '^[a-z][a-z0-9_-]*$', 'once'))
    error('ColorScheme:InvalidId', ...
        'The color scheme identifier must start with a lowercase letter and contain only lowercase letters, digits, underscores, or hyphens.');
end

skill_root = fileparts(fileparts(mfilename('fullpath')));
scheme_file = fullfile(skill_root, 'assets', 'color-schemes', [scheme_id, '.json']);
if ~isfile(scheme_file)
    error('ColorScheme:UnknownScheme', 'Unknown color scheme: %s.', scheme_id);
end
contents = fileread(scheme_file);
try
    scheme = jsondecode(contents);
catch exception
    error('ColorScheme:InvalidJson', ...
        'Could not parse color scheme %s as JSON: %s', scheme_id, exception.message);
end
if ~(isstruct(scheme) && isscalar(scheme))
    error('ColorScheme:InvalidScheme', 'A color scheme must be a single JSON object.');
end

text_fields = {'id', 'display_name', 'author', 'source_note'};
for k = 1:numel(text_fields)
    field = text_fields{k};
    if ~isfield(scheme, field) || ~is_text_row(scheme.(field))
        error('ColorScheme:InvalidScheme', ...
            'Color scheme %s requires nonempty text in %s.', scheme_id, field);
    end
    scheme.(field) = char(scheme.(field));
end
if ~strcmp(scheme.id, scheme_id)
    error('ColorScheme:InvalidScheme', ...
        'The color scheme id must match its filename: %s.', scheme_id);
end

color_fields = {'categorical_colors', 'waveform_colors', 'phase_trajectory_color'};
for k = 1:numel(color_fields)
    field = color_fields{k};
    if isfield(scheme, field) && isnumeric(scheme.(field)) && ...
            isvector(scheme.(field)) && numel(scheme.(field)) == 3
        % JSON numeric vectors decode as columns; return one RGB row.
        scheme.(field) = reshape(scheme.(field), 1, 3);
    end
    if ~isfield(scheme, field) || ~is_rgb_table(scheme.(field))
        error('ColorScheme:InvalidColors', ...
            '%s must be a nonempty N-by-3 table of finite, real RGB values between 0 and 1.', field);
    end
    scheme.(field) = double(scheme.(field));
end
if size(scheme.phase_trajectory_color, 1) ~= 1
    error('ColorScheme:InvalidColors', 'phase_trajectory_color must contain exactly one RGB row.');
end

if isfield(scheme, 'categorical_source_labels')
    labels = scheme.categorical_source_labels;
    if isstring(labels)
        labels = cellstr(labels);
    end
    if ~(iscell(labels) && isvector(labels) && ...
            numel(labels) == size(scheme.categorical_colors, 1))
        error('ColorScheme:InvalidScheme', ...
            'categorical_source_labels must contain one text label per categorical color.');
    end
    for k = 1:numel(labels)
        if ~is_text_row(labels{k})
            error('ColorScheme:InvalidScheme', ...
                'Each categorical_source_labels entry must be nonempty text.');
        end
        labels{k} = char(labels{k});
    end
    scheme.categorical_source_labels = reshape(labels, 1, []);
end
end

function valid = is_text_row(value)
valid = (ischar(value) && isrow(value) && ~isempty(value)) || ...
    (isstring(value) && isscalar(value) && ~ismissing(value) && strlength(value) > 0);
end

function valid = is_rgb_table(value)
valid = isnumeric(value) && isreal(value) && ismatrix(value) && ...
    ~isempty(value) && size(value, 2) == 3 && ...
    all(isfinite(value(:))) && all(value(:) >= 0 & value(:) <= 1);
end
