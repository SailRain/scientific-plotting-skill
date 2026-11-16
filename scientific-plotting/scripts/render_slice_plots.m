function [fig, ax, cb] = render_slice_plots(slices, categories, placement, available_width_mm, options)
%RENDER_SLICE_PLOTS Fit categorical slice plots to an article placement.
%   PLACEMENT is a placement reference basename without the .md extension.
%   AVAILABLE_WIDTH_MM is the maximum width of the entire figure. Pass []
%   or omit it for the 89 mm nonspanning two-column default only.
%   OPTIONS uses the same fields as RENDER_BIFURCATION_SLICES. Specify
%   x_text_mode as 'bottom-per-column' only for confirmed shared x axes.

nonspanning = 'two-column-document-single-column';
wide = {'one-column-document-full-width', 'two-column-document-spanning'};
assert((ischar(placement) && isrow(placement)) || ...
    (isstring(placement) && isscalar(placement) && ~ismissing(placement)), ...
    'SlicePlots:InvalidPlacement', 'Supply a placement reference basename.');
placement = char(placement);
is_nonspanning = strcmp(placement, nonspanning);
assert(is_nonspanning || any(strcmp(placement, wide)), ...
    'SlicePlots:InvalidPlacement', 'Unknown slice plot placement: %s.', placement);
if nargin < 4 || isempty(available_width_mm)
    assert(is_nonspanning, 'SlicePlots:MissingAvailableWidth', ...
        'Supply the actual available width for %s in millimeters.', placement);
    available_width_mm = 89;
end
validateattributes(available_width_mm, {'numeric'}, ...
    {'scalar', 'real', 'finite', 'positive'}, mfilename, 'available_width_mm');
if nargin < 5
    options = struct();
end

constraints = struct('available_width_mm', double(available_width_mm), ...
    'is_nonspanning', is_nonspanning);
[fig, ax, cb] = render_slice_plot_figure(slices, categories, options, constraints);
end
