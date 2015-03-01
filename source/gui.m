function varargout = gui()
% MYGUI Brief description of GUI.
%       Comments displayed at the command line in response 
%       to the help command. 

% (Leave a blank line following the help.)


%%  Initialization tasks
% http://www.mathworks.com/help/matlab/creating_guis/initializing-a-programmatic-gui.html

close all

gui_State = struct('gui_Name', mfilename, ...
                   'window_props', []);

init(gui_State);

end

%%  Construct the components
% http://www.mathworks.com/help/matlab/creating_guis/creating-figures-for-programmatic-guis.html
% http://www.mathworks.com/help/matlab/creating_guis/adding-components-to-a-programmatic-gui.html

function init(gui_State)
    ss = get(0,'screensize');
    widthScreen = ss(3);
    heightScreen = ss(4);

    widthWindow = 900;
    heightWindow = 600;
    
    gui_State.window_props.wh = [widthWindow, heightWindow];
    
    %% Main window
    posVec = [  (widthScreen/2)-(widthWindow/2) , ...
        (heightScreen/2)-(heightWindow/2) , ...
        widthWindow , ...
        heightWindow];

    hMain = figure( 'MenuBar','none',...
        'Toolbar','none',...
        'Units', 'pixels', ...
        'Position', posVec,...
        'Visible','off', ...
        'Tag', 'main');
    
    guidata(hMain, gui_State);
    
    %% Tabs
    margin = 20;
    tabGroup_posVec = [ margin, ...
                        margin, ...
                        (widthWindow-2*margin), ...
                        (heightWindow-2*margin)];
    
    %% Panels
    
    % Panels for tab1
    width_panels = 860;
    
    panel1 = uipanel(hMain, 'Title', 'Select experiments folder', ...
        'Units', 'pixels', ...
        'Position', [20 520 width_panels 70], ...
        'Tag', 'panel1');
    
    panel2 = uipanel(hMain, 'Title', 'Choose experiment', ...
        'Units', 'pixels', ...
        'Position', [20 280 width_panels 230], ...
        'Tag', 'panel2');
    
    panel3 = uipanel(hMain, 'Title', 'Run experiment', ...
        'Units', 'pixels', ...
        'Position', [20 190 width_panels 80], ...
        'Tag', 'panel3');
    
    panel4 = uipanel(hMain, 'Title', 'Results', ...
        'Units', 'pixels', ...
        'Position', [20 20 width_panels 160], ...
        'Tag', 'panel4');
    
    %% Buttons
    
    button1 = uicontrol(panel1, ...
        'Style', 'pushbutton', ...
        'String', 'Browse...',...
        'Position', [20 15 80 30],...
        'Callback', @button1_callback, ...
        'Tag', 'button1');

    button2 = uicontrol(panel2, ...
        'Style', 'pushbutton', ...
        'String', 'Set custom parameters',...
        'Position', [20 15 150 30],...
        'Callback', [], ...
        'Tag', 'button2');
    
    button3 = uicontrol(panel3, ...
        'Style', 'pushbutton', ...
        'String', 'Run', ...
        'Position', [20 15 150 30],...
        'Callback', @button3_callback, ...
        'Tag', 'button3');
    
    button5 = uicontrol(panel1, ...
        'Style', 'pushbutton', ...
        'String', 'Load', ...
        'Position', [110 15 80 30],...
        'Callback', @button5_callback, ...
        'Tag', 'button5');

    %% Static text
    
    text1 = uicontrol(  panel1,...
        'Style','text',...
        'BackgroundColor', 'white', ...
        'FontSize', 10, ...
        'String','',...
        'Position',[220 20 610 18], ...
        'Tag', 'text1');
    
    text2 = uicontrol(panel2, ...
        'Style','text',...
        'BackgroundColor', 'white', ...
        'FontSize', 10, ...
        'String','No experiment has been selected.',...
        'HorizontalAlignment', 'left', ...
        'Position',[350 20 480 180], ...
        'Tag', 'text2');
    
    %% Tables
    
    table1 = uitable(   panel2, ...
        'Data', [],... 
        'ColumnName', {'Id', 'Type'},...
        'ColumnEditable', [false false], ...
        'Position', [20 60 300 140], ...
        'CellSelectionCallback', @table1_callback, ...
        'Tag', 'table1');
    
    %% Progress bar
    
    ax1 = axes( 'Units', 'pixels', ...
        'Position', [190 20 640 10], ...
        'XLim',[0 1], ...
        'YLim',[0 1],...
        'XTick',[], ...
        'YTick',[],...
        'Color','white',...
        'Box', 'on', ...
        'XColor', [0.4314  0.4314  0.4314],...
        'YColor', [0.4314  0.4314  0.4314],...
        'Parent', panel3);
    
    patch(  [0  0  0  0], [0  0  1  1], [0.4392  0.7882  0.3686],...
        'Parent', ax1, ...
        'EdgeColor', 'none', ...
        'Tag', 'progressPatch');
    
    %% Finilize window setup
    
    hMain.Visible = 'on';
    
end

%%  Initialization tasks
% http://www.mathworks.com/help/matlab/creating_guis/initializing-a-programmatic-gui.html


%%  Callbacks for MYGUI
% http://www.mathworks.com/help/matlab/creating_guis/adding-components-to-a-programmatic-gui.html
function button1_callback(hObject, callbackdata)
% Browse folder for experiments
    
    folderExperiments = uigetdir();
    
    if ischar(folderExperiments)
        
        htext1 = findobj('Tag','text1');
        htext1.String = folderExperiments;
    end
end

function table1_callback(hObject, callbackdata)
% Update description text box for selected experiment
    
    hpanel2 = findobj('Tag', 'panel2');
    htext2 = findobj('Tag','text2');
    
    if length(callbackdata.Indices) > 0
        import managers.ItemSetting

        data = getappdata(hpanel2, 'array_progsettings');

        rowSelected = callbackdata.Indices(1);

        selectedExp = data{rowSelected};

        setappdata(hpanel2, 'current_progsettings', selectedExp);
        
        % Information
        typeExp = selectedExp.returnItemSetting(ItemSetting.TYPE_EXP).value;
        numRlz = selectedExp.returnItemSetting(ItemSetting.NUM_REALIZ).value;
        inspectionStrategy = selectedExp.returnItemSetting(ItemSetting.STRATS_INSP);
        penaltyStrategy = selectedExp.returnItemSetting(ItemSetting.PEN_POLICY);
        volMaintStrategy = selectedExp.returnItemSetting(ItemSetting.STRATS_VOL_MAINT);
        mandMaintStrategy = selectedExp.returnItemSetting(ItemSetting.STRATS_MAND_MAINT);
        
        description = cell(1,0);
        
        description{end+1} = ['Type of experiment:  ', typeExp];
        description{end+1} = [''];
        description{end+1} = ['Realizations per game:  ', num2str(numRlz)];
        description{end+1} = [''];
        description{end+1} = ['Inspection strategy: ', num2str(inspectionStrategy.getIndexSelectedStrategy())];
        description{end+1} = ['Penalty strategy: ', num2str(penaltyStrategy.getIndexSelectedStrategy())];
        description{end+1} = ['Vol maint strategy: ', num2str(volMaintStrategy.getIndexSelectedStrategy())];
        description{end+1} = ['Mand maint strategy: ', num2str(mandMaintStrategy.getIndexSelectedStrategy())];
        
        htext2.String = description;
    else
        rmappdata(hpanel2, 'current_progsettings');
        htext2.String = 'No experiment has been selected.';
    end
end

function button3_callback(hObject, callbackdata)
% Runs selected experiment
    
    import managers.Experiment
    
    hpanel2 = findobj('Tag', 'panel2');
    progSettings = getappdata(hpanel2, 'current_progsettings');
    
    experiment = Experiment(progSettings);
    experiment.run()
    
    hpanel3 = findobj('Tag', 'panel3');
    setappdata(hpanel3, 'experiment', experiment);
    
    hpanel4 = findobj('Tag', 'panel4');
    child_handles = allchild(hpanel4);
    
    for i=1:length(child_handles)
        h = child_handles(i);
        delete(h);
    end
    
    typeExperiment = experiment.typeExp;
    
    switch typeExperiment
        case Experiment.SING
            data = experiment.report();
            setappdata(hpanel4, 'reportSingle', data);
            layout_SING()
            
        case Experiment.DISP
            
        case Experiment.SENS
            
        case Experiment.OPT
            
    end
end

function button4_callback(hObject, callbackdata)
% Show the history of a SING experiment
    import dataComponents.Event
    
    hFigure = figure( 'Name', 'Realization report', ...
        'NumberTitle', 'off', ...
        'MenuBar','none',...
        'Toolbar','figure',...
        'Units', 'pixels', ...
        'Position', [100 100 600 600],...
        'Visible','off', ...
        'Tag', 'realiz');
    
    hpanel4 = findobj('Tag', 'panel4');
    
    data = getappdata(hpanel4, 'reportSingle');
    
    horiz_margin = 0.05;
    vert_margin = 0.05;
    
    height = (1-4*vert_margin)/3;
    width = 0.85;
    
    boxColor = [0.35  0.35  0.35];
    
    posVec1 = [0.1    0.685    width   height];
    posVec2 = [0.1    0.375      width   height];
    posVec3 = [0.1    0.07                 width   height];
    
    ax1 = subplot('Position', posVec1, ...
        'Parent', hFigure);
    ax2 = subplot('Position', posVec2, ...
        'Parent', hFigure);
    ax3 = subplot('Position', posVec3, ...
        'Parent', hFigure);
    
    % Figure 1. Interaction sequence
    
    width_fig1 = 700;       % pixels
    height_fig1 = 400;      % pixels
    
    % ---------:::::::::::::::: Subfigure 1 ::::::::::::::::---------------
    
    %   ::::--> Degradation path
    
    finalTimePlot = (1+0.05)*data.contractDuration;
    
    set(ax1, ...
        'XLim', [0 finalTimePlot], ...
        'YLim', [data.nullPerf data.maxPerf],...
        'FontSize', 8, ...
        'Color', 'white', ...
        'Box', 'on', ...
        'XColor', boxColor,...
        'YColor', boxColor, ...
        'XTickLabel', []);
    
    hold(ax1, 'on')
    grid(ax1, 'on');
    
    hLine1 = plot(ax1, data.perfHistory.time, data.perfHistory.value);
    hLine2 = plot(ax1, [0, finalTimePlot], [data.threshold, data.threshold],':', ...
        'Color',[0.7 0 0], ...
        'LineWidth', 0.1);
    
    ylabel(ax1, 'Performance level')
    
    %   ::::--> Events markers
    
    % Inspections Only
    if ~isempty(data.inspectionMarker)
        hLine3 = plot(ax1, ...
            data.inspectionMarker.time, data.inspectionMarker.value, 'o', ...
            'MarkerEdgeColor','black', ...
            'MarkerSize', 6);
    end
    
    % Detections
    if ~isempty(data.detectionMarker)
        hLine4 = plot(ax1, ...
            data.detectionMarker.time, data.detectionMarker.value, 'd', ...
            'MarkerEdgeColor','red', ...
            'MarkerSize', 8);
    end
    
    % Maintenances
    if ~isempty(data.volMaintMarker)
        hLine5 = plot(ax1, ...
            data.volMaintMarker.time, data.volMaintMarker.value,'+', ...
            'MarkerEdgeColor',[13 209 62]/255, ...
            'MarkerFaceColor','green', ...
            'MarkerSize', 4);
    end
    
    % Shocks
    if ~isempty(data.shockMarker)
        hLine6 = plot(ax1, ...
            data.shockMarker.time, data.shockMarker.value,'x', ...
            'MarkerEdgeColor','magenta', ...
            'MarkerSize', 7);
    end
    
    hold(ax1, 'off')
    
    % ---------:::::::::::::::: Subfigure 2 ::::::::::::::::---------------
    
    set(ax2, ...
        'XLim', [0 finalTimePlot], ...
        'FontSize', 8, ...
        'Color', 'white', ...
        'Box', 'on', ...
        'XColor', boxColor,...
        'YColor', boxColor, ...
        'XTickLabel', []);
    
    % Plot Balance vs t : AGENT
    hold(ax2, 'on')
    grid(ax2, 'on');
    
    plot(ax2, data.balA.time, data.balA.balance, '-')
    plot(ax2, data.balA.time, data.balA.balance, '+', 'MarkerSize', 2, 'MarkerEdgeColor','r');
    
    %legend(ax2,'Discrete flow', 'Location', 'bestoutside')
    ylabel(ax2, 'Agent''s balance ($)')
    
    % ---------:::::::::::::::: Subfigure 3 ::::::::::::::::---------------
    
    % Plot PV vs t : PRINCIPAL
    
    set(ax3, ...
        'XLim', [0 finalTimePlot], ...
        'FontSize', 8, ...
        'Color', 'white', ...
        'Box', 'on', ...
        'XColor', boxColor,...
        'YColor', boxColor);
    
    hold(ax3, 'on')
    grid(ax3, 'on');
    
    plot(ax3, ...
        data.perceivedPerfMeanValue.time, data.perceivedPerfMeanValue.meanValue, '-o', ...
        data.realPerfMeanValue.time, data.realPerfMeanValue.meanValue,'-.');
    
    
    %plot(perfHistory.time,perfHistory.value, 'Color', [0.9 0.9 0.9])
    
    %legend(ax3, 'Perceived','Real', 'Location', 'bestoutside')
    
    xlabel(ax3, 'Time')
    ylabel(ax3, 'Mean performance')
    
    
    hFigure.Visible = 'on';
end


function button5_callback(hObject, callbackdata)

    htext1 = findobj('Tag','text1');
    folderExperiments = htext1.String;

    if ischar(folderExperiments)

        [tableData exp_array] = searchExperiments(folderExperiments);

        htext2 = findobj('Tag', 'text2');
        htext2.String = [':::  ', num2str(length(exp_array)), ' experiments successfully loaded.','  :::'];

        htable1 = findobj('Tag','table1');
        htable1.Data = tableData;

        hpanel2 = findobj('Tag', 'panel2');

        if length(exp_array) > 0
            setappdata(hpanel2, 'array_progsettings', exp_array);
        else
            rmappdata(hpanel2, 'array_progsettings');
        end
    end
end

%%  Utility functions for MYGUI

function str = getPathField()
% Get path string of experiments folder

    h = findobj('Tag','text1');
    str = h.String;
end

function updateProgressBar(value)
% Updates the progress bar to the value parameter
    p = findobj('Tag','progressPatch');
    p.XData(2:3) = value;
end

function [data_table, exp_array] = searchExperiments(folderPath)
% Return info of all experiments in folder

    import managers.ItemSetting
    
    exp_folder = what(folderPath);
    exp_number = length(exp_folder.packages);
    
    data_table = cell(exp_number, 2);
     exp_array = cell(exp_number, 1);
     
    if exp_number > 0
        
        addpath(folderPath)

        for i=1:exp_number
            settingsObject = feval([exp_folder.packages{i}, '.settings']);
            exp_array{i} = settingsObject;
            data_table{i,1} = exp_folder.packages{i};
            data_table{i,2} = settingsObject.returnItemSetting(ItemSetting.TYPE_EXP).value;
        end

    else
        warning('No experiment package was found in the specified folder.')
    end
    
end

function layout_SING()

    hpanel4 = findobj('Tag', 'panel4');

    hpanel4_1 = uipanel(hpanel4, ...
        'Title', 'Overview', ...
        'Units', 'pixels', ...
        'Position', [20 20 300 115], ...
        'Tag', 'panel4_1');

    hpanel4_2 = uipanel(hpanel4, ...
        'Title', 'Figures', ...
        'Units', 'pixels', ...
        'Position', [340 20 300 115], ...
        'Tag', 'panel4_2');

    button4 = uicontrol(hpanel4_2, ...
        'Style', 'pushbutton', ...
        'String', 'History',...
        'Position', [20 15 80 30],...
        'Callback', @button4_callback, ...
        'TooltipString', sprintf('Shows figure with interaction of players\nand the evolution of the infrastructure system'), ...
        'Tag', 'button4');

    data = getappdata(hpanel4, 'reportSingle');

    text3 = uicontrol(  hpanel4_1,...
        'Style','text',...
        'FontSize', 10, ...
        'String','E[Ua]',...
        'Position',[20 50 60 18], ...
        'Tag', 'text3');
    
    text4 = uicontrol(  hpanel4_1,...
        'Style','text',...
        'FontSize', 10, ...
        'String','E[Up]',...
        'Position',[20 20 60 18], ...
        'Tag', 'text4');
    
    text3 = uicontrol(  hpanel4_1,...
        'Style','text',...
        'Background', 'white', ...
        'FontSize', 10, ...
        'String', num2str(data.ua),...
        'Position',[100 50 120 18], ...
        'Tag', 'text5');
    
    text4 = uicontrol(  hpanel4_1,...
        'Style','text',...
        'Background', 'white', ...
        'FontSize', 10, ...
        'String', num2str(data.up),...
        'Position',[100 20 120 18], ...
        'Tag', 'text6');

end

function layout_DISP()
end

function layout_SENS()
end

function layout_OPT()
end

function plotRealizationHistory(hFigure, data)

end
