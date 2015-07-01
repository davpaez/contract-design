function [ output_args ] = report_single( input_args )

    hpanel4 = findobj('Tag', 'panel4');
    data = getappdata(hpanel4, 'reportSingle');
    
    hFigure = figure( 'Name', 'Realization report', ...
        'NumberTitle', 'off', ...
        'MenuBar','none',...
        'Toolbar','figure',...
        'Units', 'pixels', ...
        'Position', [100 100 900 600],...
        'Resize', 'off', ...
        'Visible','off', ...
        'Tag', 'realiz');
    
    panel5 = uipanel(hFigure, 'Title', 'Realization history', ...
        'Units', 'pixels', ...
        'Position', [20 20 560 570], ...
        'Tag', 'panel5');
    
    panel6 = uipanel(hFigure, 'Title', 'Indicators', ...
        'Units', 'pixels', ...
        'Position', [595 20 290 570], ...
        'Tag', 'panel6');
    
    gui.plot_history(panel5, data)
    
    table2 = uitable(panel6, ...
        'Data', [],... 
        'ColumnName', {'Field', 'Value'},...
        'ColumnEditable', [false false], ...
        'Position', [20 20 250 520], ...
        'CellSelectionCallback', [], ...
        'Tag', 'table2');
    
    populateFields(table2, data);
    
    hFigure.Visible = 'on';
    
end

function populateFields(htable, data_exp)
%{
List of indicators:
- Utility agent
- Utility principal
- Balance agent
- Balance principal
- Time below threshold
- Sum penalties
- Agent's B/C
- # inspections
- # detections
- # actual violations
- # cost of inspections
- Observed mean value perf
- Real mean value perf
- Error inspection index (area between the two curves / tm)
- cost of inspections
- cost vol maints
- cost mand maints
- std of observed performance
- std of actual performance
%}
numfields = 15;
data_table = cell(15, 2);
fields = fieldnames(data_exp);

end