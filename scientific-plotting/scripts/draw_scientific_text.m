function [group, metrics] = draw_scientific_text(ax, anchor_pt, atoms, options)
%DRAW_SCIENTIFIC_TEXT Draw editable math with explicitly raised subscripts.
%   [GROUP, METRICS] = DRAW_SCIENTIFIC_TEXT(AX, ANCHOR_PT, ATOMS, OPTIONS)
%   places text at an axes-relative physical point anchor. Each atom has a
%   literal TEXT and optional SUBSCRIPT and SUPERSCRIPT. FONT_ANGLE,
%   SUBSCRIPT_ANGLE, and SUPERSCRIPT_ANGLE are 'normal' or 'italic'. Optional
%   TEXT_SIZE_PT, SUBSCRIPT_SIZE_PT, and SUPERSCRIPT_SIZE_PT specify effective
%   glyph sizes; omitted sizes follow the native TeX expression.
%
%   OPTIONS fields: font_name ('Times New Roman'), font_size_pt (8), color
%   ([0 0 0]), rotation (0), horizontal_alignment ('left'),
%   vertical_alignment ('baseline'), subscript_raise_pt (1), and tag ('').
%   Only declared subscripts move, along the label's local upward direction.
%   Native text positions, styles, and sizes are measured in an isolated SVG.
%   Outlined SVG glyphs require complete translation-only registration against
%   original standalone glyphs at separately measured native font settings;
%   the function does not parse arbitrary TeX or infer math from underscores.
%   The result contains ordinary editable Text objects, not imported SVG.
%
%   METRICS includes extent_pt and native_extent_pt (axes-relative bounding
%   rectangles), native_tex, and per-run native/rendered physical positions.
%   Rebuild the group after geometry changes; this is not a live text ruler.

if nargin < 4 || isempty(options), options = struct(); end
validateattributes(ax, {'matlab.graphics.axis.Axes'}, {'scalar'}, mfilename, 'ax');
validateattributes(anchor_pt, {'numeric'}, {'real','finite','vector','numel',2}, mfilename, 'anchor_pt');
anchor_pt = double(reshape(anchor_pt, 1, 2));
options = normalize_options(options);
[atoms, runs, native_tex, style_tex] = normalize_atoms(atoms, options);
if ~any(strcmpi(listfonts, options.font_name))
    error('ScientificText:MissingFont', 'The requested font "%s" is unavailable.', options.font_name);
end
if ~usejava('jvm')
    error('ScientificText:MissingJava','Native SVG measurement requires MATLAB with the JVM enabled.');
end

source_figure = ancestor(ax, 'figure');
if isempty(source_figure) || ~isgraphics(source_figure)
    error('ScientificText:InvalidParent', 'The parent axes must belong to a live figure.');
end
[figure_size_pt, axes_position_pt] = physical_geometry(source_figure, ax);
old_figure = get(groot, 'CurrentFigure');
temporary_dir = tempname(tempdir);
mkdir(temporary_dir);
cleanup = onCleanup(@() clean_probe(temporary_dir, old_figure)); %#ok<NASGU>
probe = figure('Visible','off', 'HandleVisibility','off', 'Units','points', ...
    'Position',[50 50 figure_size_pt], 'Color','w', 'InvertHardcopy','off');
probe_cleanup = onCleanup(@() close_if_valid(probe)); %#ok<NASGU>
% Recreate the actual canvas and axes geometry. Screen and export rounding
% depend on physical anchors, so no normalized or enlarged calibration is used.
probe_axes = axes('Parent',probe, 'Units','points', 'Position',axes_position_pt, ...
    'Visible','off', 'XLim',[0 1], 'YLim',[0 1]);
native = text('Parent',probe_axes, 'Units','points', ...
    'Position',[anchor_pt 0], 'String',native_tex, ...
    'FontUnits','points', 'FontName',options.font_name, ...
    'FontSize',options.font_size_pt, 'Interpreter','tex', ...
    'HorizontalAlignment',options.horizontal_alignment, ...
    'VerticalAlignment',options.vertical_alignment, 'Rotation',options.rotation, ...
    'Clipping','off');
drawnow;
native_extent = native.Extent;
set(probe, 'PaperUnits','points', 'PaperSize',figure_size_pt, ...
    'PaperPosition',[0 0 figure_size_pt], 'PaperPositionMode','manual');
native_file = fullfile(temporary_dir, 'native.svg');
print(probe, native_file, '-dsvg');
native_measurements = read_svg_runs(native_file, runs, figure_size_pt, axes_position_pt);
outlined = strcmp({native_measurements.kind}, 'outline');
if any(outlined)
    % Some native SVG exports outline every run when a mathematical minus is
    % present. A safe-payload probe measures style only, never positions. The
    % original native and standalone glyph outlines below must then register
    % exactly, proving that the measured style reproduces the original glyphs.
    native.String=style_tex;
    style_file=fullfile(temporary_dir,'style.svg');
    print(probe,style_file,'-dsvg');
    style_runs=runs;
    for k=1:numel(style_runs), style_runs(k).text='Ag'; end
    styles=read_svg_runs(style_file,style_runs,figure_size_pt,axes_position_pt);
    for k=1:numel(runs)
        if ~strcmp(styles(k).kind,'text')
            error('ScientificText:UnsupportedSvg','The style probe did not preserve native font metadata.');
        end
        native_measurements(k).font_name=styles(k).font_name;
        native_measurements(k).font_size_pt=styles(k).font_size_pt;
        native_measurements(k).font_angle=styles(k).font_angle;
    end
end

delete(native);
standalone = gobjects(numel(runs),1);
for k = 1:numel(runs)
    measured = native_measurements(k);
    if ~strcmpi(measured.font_name, options.font_name)
        error('ScientificText:FontSubstitution', ...
            'Run %d exported with "%s" instead of "%s".', k, measured.font_name, options.font_name);
    end
    if ~isempty(runs(k).requested_size_pt) && abs(measured.font_size_pt-runs(k).requested_size_pt) > 0.01
        error('ScientificText:FontSizeMismatch', 'The effective font size for run %d could not be preserved.', k);
    end
    % SVG's physical mm viewport and font-size attributes are rounded during
    % serialization. Do not feed a spurious 8.000007 pt font back to MATLAB:
    % a distinct fractional font request can select different baseline metrics.
    % Explicit sizes and the native main size remain exact after measurement;
    % automatic script sizes retain the measured value to 0.0001 pt precision.
    if ~isempty(runs(k).requested_size_pt)
        measured.font_size_pt=runs(k).requested_size_pt;
    elseif strcmp(runs(k).role,'text')
        if abs(measured.font_size_pt-options.font_size_pt)>0.01
            error('ScientificText:FontSizeMismatch','The native main font size changed unexpectedly.');
        end
        measured.font_size_pt=options.font_size_pt;
    else
        measured.font_size_pt=round(measured.font_size_pt*10000)/10000;
    end
    native_measurements(k).font_size_pt=measured.font_size_pt;
    standalone(k) = make_run(probe_axes, anchor_pt, runs(k), measured, options, runs(k).probe_color);
end
drawnow;
standalone_file = fullfile(temporary_dir, 'standalone.svg');
print(probe, standalone_file, '-dsvg');
standalone_measurements = read_svg_runs(standalone_file, runs, figure_size_pt, axes_position_pt);

group = hggroup('Parent',ax, 'Tag',options.tag);
failure_cleanup = onCleanup(@() delete_failed_group(group));
rotation_matrix = [cosd(options.rotation), -sind(options.rotation); ...
    sind(options.rotation), cosd(options.rotation)];
raise_vector = (rotation_matrix * [0; options.subscript_raise_pt])';
rendered = gobjects(numel(runs),1);
for k = 1:numel(runs)
    if strcmp(native_measurements(k).kind,'outline') || strcmp(standalone_measurements(k).kind,'outline')
        if ~strcmp(native_measurements(k).kind,standalone_measurements(k).kind)
            error('ScientificText:OutlineMismatch','Native and standalone text used incompatible SVG serialization.');
        end
        native_shape=native_measurements(k).outline_points_pt;
        standalone_shape=standalone_measurements(k).outline_points_pt;
        if ~strcmp(native_measurements(k).outline_commands,standalone_measurements(k).outline_commands) || ...
                ~isequal(size(native_shape),size(standalone_shape)) || isempty(native_shape)
            error('ScientificText:OutlineMismatch','The native outline for run %d did not match its measured font.',k);
        end
        correction=native_shape(1,:)-standalone_shape(1,:);
        residual=native_shape-standalone_shape-correction;
        if any(abs(residual(:))>0.005)
            error('ScientificText:OutlineMismatch', ...
                'The complete native glyph outline for run %d could not be registered by translation.',k);
        end
    else
        correction = native_measurements(k).baseline_pt - standalone_measurements(k).baseline_pt;
    end
    position = anchor_pt + correction;
    raise = [0 0];
    if strcmp(runs(k).role, 'subscript'), raise = raise_vector; end
    rendered(k) = make_run(group, position + raise, runs(k), native_measurements(k), options, options.color);
    runs(k).native_baseline_pt = standalone_measurements(k).baseline_pt + correction;
    runs(k).rendered_baseline_pt = runs(k).native_baseline_pt + raise;
    runs(k).native_position_pt = position;
    runs(k).rendered_position_pt = position + raise;
    runs(k).font_name = native_measurements(k).font_name;
    runs(k).font_size_pt = native_measurements(k).font_size_pt;
    runs(k).font_angle = native_measurements(k).font_angle;
    runs(k).handle = rendered(k);
end
drawnow;
extent = union_extents(rendered);
metrics = struct('extent_pt',extent, 'native_extent_pt',native_extent, ...
    'native_tex',native_tex, 'anchor_pt',anchor_pt, 'runs',runs, ...
    'subscript_raise_pt',options.subscript_raise_pt, ...
    'rotation',options.rotation, 'matlab_release',version('-release'), ...
    'calibration_backend','print -dsvg (native text)', 'figure_size_pt',figure_size_pt, ...
    'axes_position_pt',axes_position_pt, 'atoms',atoms);
if any(outlined), metrics.calibration_backend='print -dsvg (registered original glyph outlines and measured style)'; end
setappdata(group, 'ScientificTextMetrics', metrics);
clear failure_cleanup;
% Close explicitly because an anonymous cleanup captures its input value.
close(probe);
probe = [];
end

function options = normalize_options(options)
if ~isstruct(options) || ~isscalar(options)
    error('ScientificText:InvalidOptions', 'Options must be a scalar structure.');
end
defaults = struct('font_name','Times New Roman', 'font_size_pt',8, ...
    'color',[0 0 0], 'rotation',0, 'horizontal_alignment','left', ...
    'vertical_alignment','baseline', 'subscript_raise_pt',1, 'tag','');
unknown = setdiff(fieldnames(options), fieldnames(defaults));
if ~isempty(unknown)
    error('ScientificText:InvalidOptions', 'Unsupported option: %s.', unknown{1});
end
names = fieldnames(defaults);
for k=1:numel(names)
    if ~isfield(options,names{k}) || isempty(options.(names{k}))
        options.(names{k}) = defaults.(names{k});
    end
end
options.font_name = scalar_text(options.font_name, 'font_name');
options.tag = scalar_text(options.tag, 'tag');
if isempty(options.font_name) || any(ismember(options.font_name, '{}\'))
    error('ScientificText:InvalidOptions', 'The font name is empty or contains unsupported TeX syntax.');
end
validateattributes(options.font_size_pt, {'numeric'}, {'scalar','real','finite','positive'});
validateattributes(options.rotation, {'numeric'}, {'scalar','real','finite'});
validateattributes(options.subscript_raise_pt, {'numeric'}, {'scalar','real','finite','nonnegative'});
validateattributes(options.color, {'numeric'}, {'real','finite','size',[1 3],'>=',0,'<=',1});
options.horizontal_alignment = validatestring(options.horizontal_alignment, {'left','center','right'});
options.vertical_alignment = validatestring(options.vertical_alignment, {'baseline','middle','top','bottom','cap'});
end

function [atoms, runs, native_tex, style_tex] = normalize_atoms(atoms, options)
if ~isstruct(atoms) || isempty(atoms) || ~isvector(atoms) || ~isfield(atoms,'text')
    error('ScientificText:InvalidAtoms', 'Atoms must be a nonempty structure vector with a text field.');
end
allowed = {'text','subscript','superscript','font_angle','subscript_angle', ...
    'superscript_angle','text_size_pt','subscript_size_pt','superscript_size_pt'};
unknown = setdiff(fieldnames(atoms), allowed);
if ~isempty(unknown)
    error('ScientificText:InvalidAtoms', 'Unsupported atom field: %s.', unknown{1});
end
template = struct('atom_index',0, 'role','', 'text','', 'requested_size_pt',[], ...
    'probe_color',[], 'probe_hex','');
runs = repmat(template,0,1);
native_tex = '';
style_tex = '';
roles = {'text','subscript','superscript'};
for a=1:numel(atoms)
    if isempty(scalar_text(atoms(a).text,'text'))
        error('ScientificText:InvalidAtoms', 'Each atom needs nonempty literal text.');
    end
    atom_tex = '';
    atom_style_tex = '';
    for part=1:3
        role = roles{part};
        if ~isfield(atoms,role) || isempty(atoms(a).(role)), continue; end
        value = scalar_text(atoms(a).(role), role);
        if isempty(value), continue; end
        if all(isspace(value))
            error('ScientificText:UnsupportedText', ...
                'Put separator whitespace in a neighboring visible literal atom; whitespace-only runs have no measurable glyphs.');
        end
        if any(ismember(value, [char(10),char(13),char(9),'{}^\']))
            error('ScientificText:UnsupportedText', ...
                'Atom text must be single-line literal text without braces, carets, or TeX commands.');
        end
        if part==1, angle_field='font_angle'; else, angle_field=[role '_angle']; end
        angle = 'normal';
        if isfield(atoms,angle_field) && ~isempty(atoms(a).(angle_field))
            angle = validatestring(atoms(a).(angle_field), {'normal','italic'});
        end
        size_field = [role '_size_pt'];
        size_pt = [];
        if isfield(atoms,size_field) && ~isempty(atoms(a).(size_field))
            size_pt=atoms(a).(size_field);
            validateattributes(size_pt, {'numeric'}, {'scalar','real','finite','positive'});
        end
        index = numel(runs)+1;
        if index > 20000
            error('ScientificText:TooManyRuns', 'A label supports at most 20000 explicitly mapped runs.');
        end
        rgb_bytes = [20+mod(index-1,200), 20+floor((index-1)/200), 131];
        run = template;
        run.atom_index=a; run.role=role; run.text=value;
        run.requested_size_pt=size_pt; run.probe_color=rgb_bytes/255;
        run.probe_hex=lower(sprintf('#%02x%02x%02x',rgb_bytes));
        runs(end+1,1)=run; %#ok<AGROW>
        format = sprintf('\\color[rgb]{%.12g %.12g %.12g}\\fontname{%s}\\rm{}', ...
            run.probe_color,options.font_name);
        if strcmp(angle,'italic'), format=[format '\it{}']; end %#ok<AGROW>
        if ~isempty(size_pt), format=[format sprintf('\\fontsize{%.12g}',size_pt)]; end %#ok<AGROW>
        value=strrep(value,'_','\_');
        fragment=['{' format value '}'];
        style_fragment=['{' format 'Ag}'];
        if part==2, fragment=['_' fragment]; end
        if part==3, fragment=['^' fragment]; end
        if part==2, style_fragment=['_' style_fragment]; end
        if part==3, style_fragment=['^' style_fragment]; end
        atom_tex=[atom_tex fragment]; %#ok<AGROW>
        atom_style_tex=[atom_style_tex style_fragment]; %#ok<AGROW>
    end
    native_tex=[native_tex atom_tex]; %#ok<AGROW>
    style_tex=[style_tex atom_style_tex]; %#ok<AGROW>
end
end

function text_value = scalar_text(value, name)
if isstring(value) && isscalar(value), value=char(value); end
if ~ischar(value) || (~isempty(value) && ~isrow(value))
    error('ScientificText:InvalidText', '%s must be a character row or scalar string.',name);
end
text_value=value;
end

function [figure_size, axes_position] = physical_geometry(fig, ax)
original_units=fig.Units;
cleanup=onCleanup(@() set(fig,'Units',original_units)); %#ok<NASGU>
fig.Units='points';
figure_size=double(fig.Position(3:4));
pixels=getpixelposition(ax,true);
axes_position=hgconvertunits(fig,pixels,'pixels','points',fig);
if any(~isfinite([figure_size axes_position])) || any(figure_size<=0) || any(axes_position(3:4)<=0)
    error('ScientificText:InvalidGeometry', 'The figure and axes must have finite positive physical geometry.');
end
end

function object = make_run(parent, position, run, measured, options, color)
object=text('Parent',parent, 'Units','points', 'Position',[position 0], ...
    'String',run.text, 'Interpreter','none', 'FontUnits','points', ...
    'FontName',measured.font_name, 'FontSize',measured.font_size_pt, ...
    'FontAngle',measured.font_angle, 'FontWeight','normal', 'Color',color, ...
    'Rotation',options.rotation, 'HorizontalAlignment','left', ...
    'VerticalAlignment','baseline', 'Clipping','off', ...
    'Tag',sprintf('%s_atom_%d_%s',options.tag,run.atom_index,run.role));
end

function measurements = read_svg_runs(filename, runs, figure_size, axes_position)
try
    document=xmlread(filename);
catch cause
    error('ScientificText:SvgReadFailed', 'The native SVG could not be read: %s',cause.message);
end
root=document.getDocumentElement;
view_box=parse_numbers(char(root.getAttribute('viewBox')));
if numel(view_box)~=4 || any(view_box(3:4)<=0)
    error('ScientificText:UnsupportedSvg', 'The native SVG has an unsupported viewport.');
end
% Native SVG rounds its canvas up to device coordinates. Read its declared
% physical viewport instead of stretching that rounded canvas back to the
% requested figure size, which would distort noninteger-point font sizes.
svg_size=[svg_length_pt(char(root.getAttribute('width'))), ...
    svg_length_pt(char(root.getAttribute('height')))];
aspect=char(root.getAttribute('preserveAspectRatio'));
if isempty(aspect),aspect='xMidYMid meet';end
if strcmp(strtrim(aspect),'none')
    root_map=[svg_size(1)/view_box(3),0,-view_box(1)*svg_size(1)/view_box(3); ...
        0,svg_size(2)/view_box(4),-view_box(2)*svg_size(2)/view_box(4);0,0,1];
else
    token=regexp(strtrim(aspect),'^x(Min|Mid|Max)Y(Min|Mid|Max)(?:\s+(meet|slice))?$','tokens','once');
    if isempty(token),error('ScientificText:UnsupportedSvg','Unsupported SVG viewport alignment.');end
    ratio=svg_size./view_box(3:4);
    if numel(token)>=3 && strcmp(token{3},'slice'),scale=max(ratio);else,scale=min(ratio);end
    fractions=struct('Min',0,'Mid',0.5,'Max',1);
    remainder=svg_size-view_box(3:4)*scale;
    offset=[remainder(1)*fractions.(token{1}),remainder(2)*fractions.(token{2})];
    root_map=[scale 0 offset(1)-view_box(1)*scale;0 scale offset(2)-view_box(2)*scale;0 0 1];
end
measurements=repmat(struct('baseline_pt',[], 'font_name','', 'font_size_pt',[], ...
    'font_angle','', 'kind','', 'outline_points_pt',[], 'outline_commands',''), numel(runs),1);
counts=zeros(numel(runs),1);
elements=document.getElementsByTagName('text');
for n=0:elements.getLength-1
    node=elements.item(n);
    color=lower(inherited_attribute(node,'fill'));
    index=find(strcmp({runs.probe_hex},color));
    if isempty(index), continue; end
    if numel(index)~=1 || counts(index)>0 || node.getElementsByTagName('tspan').getLength>0
        error('ScientificText:UnsupportedSvg', 'A declared text part did not export as one unambiguous SVG run.');
    end
    content=char(node.getTextContent);
    if ~strcmp(content,runs(index).text)
        error('ScientificText:RunMappingFailed', ...
            'Native text content changed for run %d (expected "%s", received "%s").', ...
            index,runs(index).text,content);
    end
    x=parse_numbers(char(node.getAttribute('x'))); y=parse_numbers(char(node.getAttribute('y')));
    if numel(x)~=1 || numel(y)~=1
        error('ScientificText:UnsupportedSvg', 'Per-character SVG position arrays are not supported.');
    end
    transform=node_transform(node,root_map);
    baseline=transform*[x;y;1];
    baseline=[baseline(1)-axes_position(1),svg_size(2)-baseline(2)-axes_position(2)];
    scale_x=norm(transform(1:2,1)); scale_y=norm(transform(1:2,2));
    if abs(scale_x-scale_y)>1e-5 || abs(dot(transform(1:2,1),transform(1:2,2)))>1e-5
        error('ScientificText:UnsupportedSvg', 'An anisotropic text transform cannot preserve physical font sizes.');
    end
    font_size=parse_numbers(inherited_attribute(node,'font-size'));
    font_family=inherited_attribute(node,'font-family');
    font_angle=inherited_attribute(node,'font-style');
    font_weight=inherited_attribute(node,'font-weight');
    if numel(font_size)~=1 || ~ismember(font_angle,{'normal','italic'}) || ...
            ~ismember(font_weight,{'400','normal'})
        error('ScientificText:UnsupportedSvg', 'The native font style could not be preserved.');
    end
    measurements(index)=struct('baseline_pt',baseline,'font_name',font_family, ...
        'font_size_pt',font_size*scale_x,'font_angle',font_angle, ...
        'kind','text','outline_points_pt',[],'outline_commands','');
    counts(index)=counts(index)+1;
end
paths=document.getElementsByTagName('path');
for n=0:paths.getLength-1
    node=paths.item(n);
    color=lower(inherited_attribute(node,'fill'));
    index=find(strcmp({runs.probe_hex},color));
    if isempty(index), continue; end
    if numel(index)~=1 || counts(index)>0
        error('ScientificText:UnsupportedSvg','An outlined part has ambiguous or split SVG paths.');
    end
    [points,commands]=outline_points(char(node.getAttribute('d')));
    transform=node_transform(node,root_map);
    physical=(transform*[points';ones(1,size(points,1))])';
    physical=[physical(:,1)-axes_position(1),svg_size(2)-physical(:,2)-axes_position(2)];
    origin=transform*[0;0;1];
    baseline=[origin(1)-axes_position(1),svg_size(2)-origin(2)-axes_position(2)];
    measurements(index)=struct('baseline_pt',baseline,'font_name','', ...
        'font_size_pt',[],'font_angle','', 'kind','outline', ...
        'outline_points_pt',physical,'outline_commands',commands);
    counts(index)=counts(index)+1;
end
if any(counts~=1)
    error('ScientificText:RunMappingFailed', ...
        'Every declared part must have exactly one mapped native SVG text or glyph-outline run.');
end
end

function value=svg_length_pt(text_value)
token=regexp(strtrim(text_value),'^([+\-0-9.eE]+)\s*(mm|cm|in|pt|pc|px)?$','tokens','once');
if isempty(token)
    error('ScientificText:UnsupportedSvg','The SVG physical viewport has an unsupported length unit.');
end
value=str2double(token{1});
unit='px'; if numel(token)>1 && ~isempty(token{2}),unit=token{2};end
switch unit
    case 'mm',value=value*72/25.4;
    case 'cm',value=value*72/2.54;
    case 'in',value=value*72;
    case 'pc',value=value*12;
    case 'px',value=value*72/96;
end
if ~isfinite(value) || value<=0
    error('ScientificText:UnsupportedSvg','The SVG physical viewport must be finite and positive.');
end
end

function transform=node_transform(node,root_map)
chain={}; cursor=node;
while ~isempty(cursor) && cursor.getNodeType==1
    chain{end+1}=cursor; %#ok<AGROW>
    cursor=cursor.getParentNode;
end
transform=root_map;
for c=numel(chain):-1:1
    transform=transform*svg_transform(char(chain{c}.getAttribute('transform')));
end
end

function [points,signature]=outline_points(value)
% Qt's glyph paths use absolute move, line, cubic, and quadratic coordinates.
% Accept that narrow serialization only; do not approximate arbitrary paths.
tokens=regexp(value,'([MmLlHhVvCcSsQqTtAaZz])([^MmLlHhVvCcSsQqTtAaZz]*)','tokens');
points=zeros(0,2); signature='';
for k=1:numel(tokens)
    command=tokens{k}{1};
    values=parse_numbers(tokens{k}{2});
    if strcmpi(command,'Z')
        if ~isempty(values), invalid_outline; end
        signature=[signature 'Z;']; %#ok<AGROW>
        continue;
    end
    if ~ismember(command,{'M','L','C','Q'}) || isempty(values) || mod(numel(values),2)~=0
        invalid_outline;
    end
    if strcmp(command,'C') && mod(numel(values),6)~=0, invalid_outline; end
    if strcmp(command,'Q') && mod(numel(values),4)~=0, invalid_outline; end
    points=[points;reshape(values,2,[])']; %#ok<AGROW>
    signature=[signature sprintf('%s%d;',command,numel(values))]; %#ok<AGROW>
end
if isempty(points), invalid_outline; end
end

function invalid_outline
error('ScientificText:UnsupportedSvg','The native glyph path uses unsupported or ambiguous SVG geometry.');
end

function value=inherited_attribute(node,name)
value='';
while ~isempty(node) && node.getNodeType==1
    if node.hasAttribute(name)
        value=char(node.getAttribute(name)); return;
    end
    if node.hasAttribute('style')
        token=regexp(char(node.getAttribute('style')),[ '(?:^|;)\s*' name '\s*:\s*([^;]+)'],'tokens','once');
        if ~isempty(token), value=strtrim(token{1}); return; end
    end
    node=node.getParentNode;
end
end

function values=parse_numbers(value)
parts=regexp(value,'[-+]?(?:\d*\.\d+|\d+\.?\d*)(?:[eE][-+]?\d+)?','match');
values=cellfun(@str2double,parts);
end

function transform=svg_transform(value)
transform=eye(3);
if isempty(strtrim(value)), return; end
tokens=regexp(value,'([A-Za-z]+)\s*\(([^)]*)\)','tokens');
if isempty(tokens)
    error('ScientificText:UnsupportedSvg','An SVG transform could not be parsed.');
end
for k=1:numel(tokens)
    numbers=parse_numbers(tokens{k}{2});
    switch tokens{k}{1}
        case 'matrix'
            if numel(numbers)~=6, invalid_transform; end
            next=[numbers(1) numbers(3) numbers(5);numbers(2) numbers(4) numbers(6);0 0 1];
        case 'translate'
            if ~ismember(numel(numbers),[1 2]), invalid_transform; end
            if numel(numbers)==1, numbers(2)=0; end
            next=[1 0 numbers(1);0 1 numbers(2);0 0 1];
        case 'scale'
            if ~ismember(numel(numbers),[1 2]), invalid_transform; end
            if numel(numbers)==1, numbers(2)=numbers(1); end
            next=diag([numbers 1]);
        case 'rotate'
            if ~ismember(numel(numbers),[1 3]), invalid_transform; end
            next=[cosd(numbers(1)) -sind(numbers(1)) 0;sind(numbers(1)) cosd(numbers(1)) 0;0 0 1];
            if numel(numbers)==3
                origin=[1 0 numbers(2);0 1 numbers(3);0 0 1];
                next=origin*next/origin;
            end
        case 'skewX'
            if numel(numbers)~=1, invalid_transform; end
            next=[1 tand(numbers(1)) 0;0 1 0;0 0 1];
        case 'skewY'
            if numel(numbers)~=1, invalid_transform; end
            next=[1 0 0;tand(numbers(1)) 1 0;0 0 1];
        otherwise
            invalid_transform;
    end
    transform=transform*next;
end
end

function invalid_transform
error('ScientificText:UnsupportedSvg','An unsupported SVG ancestor transform was encountered.');
end

function extent=union_extents(handles)
extents=zeros(numel(handles),4);
for k=1:numel(handles), extents(k,:)=handles(k).Extent; end
left=min(extents(:,1)); bottom=min(extents(:,2));
extent=[left bottom max(extents(:,1)+extents(:,3))-left max(extents(:,2)+extents(:,4))-bottom];
end

function clean_probe(directory,old_figure)
if isfolder(directory), rmdir(directory,'s'); end
if ~isempty(old_figure) && isgraphics(old_figure), set(groot,'CurrentFigure',old_figure); end
end

function close_if_valid(probe)
if isgraphics(probe), close(probe); end
end

function delete_failed_group(group)
if isgraphics(group) && ~isappdata(group,'ScientificTextMetrics'), delete(group); end
end
