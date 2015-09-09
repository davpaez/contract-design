function create_table_dispersion(panel, data_disp)

    w = panel.Position(3);
    h = panel.Position(4);
    margin = 15;
    
    htable3 = uitable(panel, ...
        'Data', [],...
        'FontSize', 10, ...
        'ColumnName', {'Field', 'Mean', 'COV'},...
        'ColumnWidth', {150 80 80}, ...
        'ColumnEditable', [false false false], ...
        'Position', [margin margin+50 w-2*margin h-2.5*margin-50], ...
        'CellSelectionCallback', @table3_callback, ...
        'Tag', 'table3');
    
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
    data_table = cell(0, 2);

    fields = returnFields();

    for i=1:numel(fields)
        entry = data_disp.getEntry(fields{i});
        data_table{i,1} = entry.description;
        data_table{i,2} = entry.mean;
        data_table{i,3} = entry.cov;
    end

    htable3.Data = data_table;

end

function table3_callback(hObject, callbackdata)

if ~isempty(callbackdata.Indices)
    
    hpanel7 = findobj('Tag', 'panel7');
    
    selectedRows = callbackdata.Indices(:,1);
    n = length(selectedRows);
    
    fields = returnFields();
    
    if n < 2
        kw = fields(selectedRows);
    else
        key1 = fields{selectedRows(1)};
        key2 = fields{selectedRows(2)};
        kw = {key1,key2};
    end
    setappdata(hpanel7, 'kw', kw);
end

end

function f = returnFields()
f = {
    'ua', ...
    'up', ...
    'final_ba', ...
    'final_bp', ...
    'final_rpmv', ...
    'final_ppmv', ...
    };
end