function tests = test_scientific_text
%TEST_SCIENTIFIC_TEXT Check measured, editable subscript typography.
%   All verification figures and SVG calibration files stay outside the repo.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
root=fileparts(fileparts(mfilename('fullpath')));
testCase.TestData.original_path=path;
addpath(fullfile(root,'scientific-plotting','scripts'),'-begin');
testCase.TestData.output_dir=tempname(tempdir);
mkdir(testCase.TestData.output_dir);
assert(any(strcmpi(listfonts,'Times New Roman')), ...
    'ScientificTextTests:MissingFont','Install Times New Roman before running these tests.');
fprintf('Scientific text verification outputs: %s\n',testCase.TestData.output_dir);
end

function teardownOnce(testCase)
path(testCase.TestData.original_path);
end

function testDeclaredRunsAndExactLocalShift(testCase)
[fig,ax]=fixture; cleanup=onCleanup(@() close(fig)); %#ok<NASGU>
cases={struct('text','λ','subscript','1','font_angle','italic'), ...
    struct('text','λ','subscript','2','font_angle','italic'), ...
    struct('text','v','subscript','C','font_angle','italic','subscript_angle','italic'), ...
    struct('text','v','subscript','φ','font_angle','italic','subscript_angle','italic'), ...
    struct('text','p','subscript','input','font_angle','italic'), ...
    struct('text','λ','subscript','12','superscript','−1','font_angle','italic')};
for k=1:numel(cases)
    [group,metrics]=draw_scientific_text(ax,[35 100],cases{k});
    verifyTrue(testCase,isgraphics(group,'hggroup'));
    verifyTrue(testCase,all(isgraphics([metrics.runs.handle],'text')));
    verifyEqual(testCase,numel(group.Children),numel(metrics.runs));
    for n=1:numel(metrics.runs)
        run=metrics.runs(n);
        expected=[0 0];
        if strcmp(run.role,'subscript'), expected=[0 1]; end
        verifyEqual(testCase,run.rendered_position_pt-run.native_position_pt,expected,'AbsTol',1e-10);
        verifyEqual(testCase,run.rendered_baseline_pt-run.native_baseline_pt,expected,'AbsTol',1e-10);
        verifyEqual(testCase,run.handle.String,run.text);
        verifyEqual(testCase,run.handle.FontSize,run.font_size_pt,'AbsTol',1e-10);
        verifyEqual(testCase,run.handle.Interpreter,'none');
        verifyEqual(testCase,run.handle.FontName,'Times New Roman');
    end
    verifyTrue(testCase,all(isfinite(metrics.extent_pt)));
    verifyGreaterThan(testCase,metrics.extent_pt(3:4),[0 0]);
    delete(group);
end
end

function testRotationsAndFixedPointShift(testCase)
[fig,ax]=fixture; cleanup=onCleanup(@() close(fig)); %#ok<NASGU>
for size=[8 10]
    for rotation=[0 90 -15 30]
        atom=struct('text','v','subscript','C','superscript','2','font_angle','italic','subscript_angle','italic');
        options=struct('rotation',rotation,'font_size_pt',size);
        [group,metrics]=draw_scientific_text(ax,[100 100],atom,options);
        expected=[-sind(rotation),cosd(rotation)];
        sub=metrics.runs(strcmp({metrics.runs.role},'subscript'));
        verifyEqual(testCase,sub.rendered_position_pt-sub.native_position_pt,expected,'AbsTol',1e-10);
        main=metrics.runs(strcmp({metrics.runs.role},'text'));
        verifyEqual(testCase,main.font_size_pt,size,'AbsTol',1e-4);
        delete(group);
    end
end
end

function testNativeAlignmentAndFreshCalls(testCase)
[fig,ax]=fixture; cleanup=onCleanup(@() close(fig)); %#ok<NASGU>
atom=struct('text','v','subscript','C','font_angle','italic');
for alignment={'left','center','right'}
    for vertical={'baseline','middle','top'}
        options=struct('horizontal_alignment',alignment{1},'vertical_alignment',vertical{1});
        [first,m1]=draw_scientific_text(ax,[100 100],atom,options);
        [second,m2]=draw_scientific_text(ax,[100 100],atom,options);
        verifyEqual(testCase,m1.native_extent_pt,m2.native_extent_pt,'AbsTol',1e-10);
        verifyEqual(testCase,m1.extent_pt,m2.extent_pt,'AbsTol',1e-10);
        verifyEqual(testCase,vertcat(m1.runs.rendered_position_pt),vertcat(m2.runs.rendered_position_pt),'AbsTol',1e-10);
        verifyEqual(testCase,[m1.runs.font_size_pt],[m2.runs.font_size_pt],'AbsTol',1e-10);
        delete([first second]);
    end
end
end

function testLiteralUnderscoresAndMixedAtoms(testCase)
[fig,ax]=fixture; cleanup=onCleanup(@() close(fig)); %#ok<NASGU>
atoms=struct('text',{'data_1.csv',', time-response Run-1'}, ...
    'subscript',{'1',[]},'superscript',{[],[]},'font_angle',{[],[]}, ...
    'text_size_pt',{[],[]});
[group,metrics]=draw_scientific_text(ax,[20 100],atoms);
verifyEqual(testCase,{metrics.runs.text},{'data_1.csv','1',', time-response Run-1'});
verifyEqual(testCase,{metrics.runs.role},{'text','subscript','text'});
verifyEqual(testCase,numel(group.Children),3);
end

function testExplicitEffectiveSizesAndNoAccumulation(testCase)
[fig,ax]=fixture; cleanup=onCleanup(@() close(fig)); %#ok<NASGU>
atom=struct('text','v','subscript','C','superscript','−1', ...
    'text_size_pt',10,'subscript_size_pt',7,'superscript_size_pt',6);
[group,metrics]=draw_scientific_text(ax,[50 100],atom,struct('subscript_raise_pt',0));
verifyEqual(testCase,[metrics.runs.font_size_pt],[10 7 6],'AbsTol',0.01);
verifyEqual(testCase,vertcat(metrics.runs.rendered_position_pt),vertcat(metrics.runs.native_position_pt),'AbsTol',1e-10);
delete(group);
[~,metrics]=draw_scientific_text(ax,[50 100],atom,struct('subscript_raise_pt',1));
sub=metrics.runs(strcmp({metrics.runs.role},'subscript'));
verifyEqual(testCase,sub.rendered_position_pt-sub.native_position_pt,[0 1],'AbsTol',1e-10);
end

function testFigureStateAndEditableReopen(testCase)
[fig,ax]=fixture; cleanup=onCleanup(@() close_if_valid(fig)); %#ok<NASGU>
set(groot,'CurrentFigure',fig); fig.CurrentAxes=ax;
original=struct('fig_units',fig.Units,'axes_units',ax.Units, ...
    'axes_position',ax.Position,'limits',[ax.XLim ax.YLim], ...
    'figures',numel(findall(groot,'Type','figure')));
[group,metrics]=draw_scientific_text(ax,[50 100], ...
    struct('text','λ','subscript','1','font_angle','italic'),struct('tag','editable_label'));
verifyEqual(testCase,get(groot,'CurrentFigure'),fig);
verifyEqual(testCase,fig.CurrentAxes,ax);
verifyEqual(testCase,fig.Units,original.fig_units);
verifyEqual(testCase,ax.Units,original.axes_units);
verifyEqual(testCase,ax.Position,original.axes_position);
verifyEqual(testCase,[ax.XLim ax.YLim],original.limits);
verifyEqual(testCase,numel(findall(groot,'Type','figure')),original.figures);
filename=fullfile(testCase.TestData.output_dir,'editable_text.fig');
savefig(fig,filename);
reopened=openfig(filename,'invisible'); close_reopened=onCleanup(@() close(reopened)); %#ok<NASGU>
saved=findall(reopened,'Tag','editable_label');
verifyEqual(testCase,numel(saved),1);
verifyTrue(testCase,all(isgraphics(saved.Children,'text')));
verifyEqual(testCase,numel(saved.Children),numel(metrics.runs));
first=saved.Children(1); first.String='Edited';
verifyEqual(testCase,first.String,'Edited');
verifyTrue(testCase,isgraphics(group));
end

function testInvalidInputsAndNoFigureLeaks(testCase)
[fig,ax]=fixture; cleanup=onCleanup(@() close(fig)); %#ok<NASGU>
before=numel(findall(groot,'Type','figure'));
verifyError(testCase,@() draw_scientific_text(ax,[10 20],struct('text','x_{1}')), ...
    'ScientificText:UnsupportedText');
verifyError(testCase,@() draw_scientific_text(ax,[10 20],struct('text',"")), ...
    'ScientificText:InvalidAtoms');
verifyError(testCase,@() draw_scientific_text(ax,[10 20],struct('text',' ')), ...
    'ScientificText:UnsupportedText');
verifyError(testCase,@() draw_scientific_text(ax,[10 20],struct('text','x','nested',struct())), ...
    'ScientificText:InvalidAtoms');
verifyError(testCase,@() draw_scientific_text(ax,[10 20],struct('text','x'),struct('guess_tex',true)), ...
    'ScientificText:InvalidOptions');
verifyError(testCase,@() draw_scientific_text(ax,[10 20],struct('text','x'),struct('font_name','Missing Font Fixture')), ...
    'ScientificText:MissingFont');
verifyEqual(testCase,numel(findall(groot,'Type','figure')),before);
end

function [fig,ax]=fixture
fig=figure('Visible','off','Units','points','Position',[60 60 420 260], ...
    'Color','w','InvertHardcopy','off');
ax=axes('Parent',fig,'Units','points','Position',[20 20 380 220], ...
    'XLim',[-2 3],'YLim',[-5 7],'Visible','off');
end

function close_if_valid(fig)
if isgraphics(fig),close(fig);end
end
