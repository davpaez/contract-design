function create_table_single(panel, data)
    
    w = panel.Position(3);
    h = panel.Position(4);
    margin = 15;
    
    htable2 = uitable(panel, ...
        'Data', [],...
        'FontSize', 10, ...
        'ColumnName', {'Field', 'Value'},...
        'ColumnWidth', {150 80}, ...
        'ColumnEditable', [false false], ...
        'Position', [margin margin w-2*margin h-2.5*margin], ...
        'CellSelectionCallback', [], ...
        'Tag', 'table2');
    
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

    fields = {
        'ua', ...
        'up', ...
        'numInspNoViol', ...
        'numDetections', ...
        'numInspections', ...
        'violationRatio', ...
        'final_bp',...
        'final_rpmv', ...
        'final_ppmv', ...
        };

    for i=1:numel(fields)
        data_table{i,1} = data.getDescription(fields{i});
        data_table{i,2} = data.getValue(fields{i});
    end

    htable2.Data = data_table;
    
end

