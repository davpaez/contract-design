%{

Variable names for UI elements must be enumerated incrementally according
their position in its parent panel in the direction left to right and top
to bottom.

Initialization tasks
http://www.mathworks.com/help/matlab/creating_guis/initializing-a-programmatic-gui.html

Construct the components
http://www.mathworks.com/help/matlab/creating_guis/creating-figures-for-programmatic-guis.html
http://www.mathworks.com/help/matlab/creating_guis/adding-components-to-a-programmatic-gui.html

%}

function gui()

close all

gui_State = struct('gui_Name', mfilename, ...
    'window_props', []);

layoutMainWindow(gui_State);

end



function layoutMainWindow(gui_State)

    ss = get(0,'screensize');
    widthScreen = ss(3);
    heightScreen = ss(4);

    widthWindow = 900;
    heightWindow = 500;
    
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
        'Resize', 'off', ...
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
        'Position', [20 420 width_panels 70], ...
        'Tag', 'panel1');
    
    panel2 = uipanel(hMain, 'Title', 'Choose experiment', ...
        'Units', 'pixels', ...
        'Position', [20 190 width_panels 230], ...
        'Tag', 'panel2');
    
    panel3 = uipanel(hMain, 'Title', 'Run experiment', ...
        'Units', 'pixels', ...
        'Position', [20 100 width_panels 80], ...
        'Tag', 'panel3');
    
    panel4 = uipanel(hMain, 'Title', 'Results', ...
        'Units', 'pixels', ...
        'Position', [20 10 width_panels 80], ...
        'Tag', 'panel4');
    
    %% Buttons
    % Browse button
    button1 = uicontrol(panel1, ...
        'Style', 'pushbutton', ...
        'String', 'Browse...',...
        'Position', [20 15 80 30],...
        'Callback', @button1_callback, ...
        'Tag', 'button1');
    
    % Load experiment button
    button2 = uicontrol(panel1, ...
        'Style', 'pushbutton', ...
        'String', 'Load', ...
        'Position', [110 15 80 30],...
        'Callback', @button2_callback, ...
        'Tag', 'button2');
    
    % Custom parameters button
    button3 = uicontrol(panel2, ...
        'Style', 'pushbutton', ...
        'String', 'Set custom parameters',...
        'Position', [20 15 150 30],...
        'Callback', @button3_callback, ...
        'Tag', 'button3');
    
    % Run button
    button4 = uicontrol(panel3, ...
        'Style', 'pushbutton', ...
        'String', 'Run', ...
        'Position', [20 15 150 30],...
        'Callback', @button4_callback, ...
        'Tag', 'button4');
    
    % Report experiment button    button4 = uicontrol(panel3, ...
    button5 = uicontrol(panel4, ...
        'Style', 'pushbutton', ...
        'String', 'Show report...', ...
        'Position', [20 15 150 30],...
        'Callback', @button5_callback, ...
        'Tag', 'button5', ...
        'Enable', 'off');
    
    % Save experiment button
    button6 = uicontrol(panel4, ...
        'Style', 'pushbutton', ...
        'String', 'Save experiment...', ...
        'Position', [190 15 150 30],...
        'Callback', @button6_callback, ...
        'Tag', 'button6', ...
        'Enable', 'off');
    
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
        'Tag', 'progresspatch');
    
    %% Finilize window setup
    
    hMain.Visible = 'on';
    
end


%%  Initialization tasks
% http://www.mathworks.com/help/matlab/creating_guis/initializing-a-programmatic-gui.html


%%  Callbacks for MYGUI
% http://www.mathworks.com/help/matlab/creating_guis/adding-components-to-a-programmatic-gui.html


function button1_callback(hObject, callbackdata)
% Opens file exporer to select folder with experiments
    
    folderExperiments = uigetdir();
    
    if ischar(folderExperiments)
        
        htext1 = findobj('Tag','text1');
        htext1.String = folderExperiments;
    end
end


function button2_callback(hObject, callbackdata)
% Loads experiment

    htext1 = findobj('Tag','text1');
    folderExperiments = htext1.String;

    if ischar(folderExperiments)

        [tableData exp_array] = searchExperiments(folderExperiments);

        htext2 = findobj('Tag', 'text2');
        htext2.String = [':::  ', num2str(length(exp_array)), ' experiments successfully loaded.','  :::'];

        htable1 = findobj('Tag','table1');
        htable1.Data = tableData;

        hpanel2 = findobj('Tag', 'panel2');
        
        % Remove all appdata
        remove_programsettings();
        remove_experiment();
        remove_reports();
        
        if length(exp_array) > 0
            setappdata(hpanel2, 'array_progsettings', exp_array);
        end
        
        button5 = findobj('Tag', 'button5');
        button6 = findobj('Tag', 'button6');

        button5.Enable = 'off';
        button6.Enable = 'off';
    end
end


function button3_callback(hObject, callbackdata)
% Set custom parameters for decision rules
    
end


function button4_callback(hObject, callbackdata)
% Runs selected experiment
    
    import managers.Experiment
    
    remove_experiment();
    remove_reports();
    
    hpanel2 = findobj('Tag', 'panel2');
    progSettings = getappdata(hpanel2, 'current_progsettings');
    
    experiment = Experiment(progSettings);
    experiment.run()
    
    hpanel3 = findobj('Tag', 'panel3');
    
    setappdata(hpanel3, 'experiment', experiment);
    
    button5 = findobj('Tag', 'button5');
    button6 = findobj('Tag', 'button6');
    
    button5.Enable = 'on';
    button6.Enable = 'on';
end


function button5_callback(hObject, callbackdata)
% Reports experiment
    
    import managers.Experiment
    
    hpanel3 = findobj('Tag', 'panel3');
    experiment = getappdata(hpanel3, 'experiment');
    typeExperiment = experiment.typeExp;
    
    hpanel4 = findobj('Tag', 'panel4');
    
    switch typeExperiment
        
        case Experiment.SING
            data = getappdata(hpanel4, 'reportSingle');
            if isempty(data)
                data = experiment.report();
                setappdata(hpanel4, 'reportSingle', data);
            end
            
            % Launches report window
            gui.report_single()
            
        case Experiment.DISP
            data = getappdata(hpanel4, 'reportDispersion');
            if isempty(data)
                data = experiment.report();
                setappdata(hpanel4, 'reportDispersion', data);
            end
            
            % Launches report window
            gui.report_dispersion()
            
        case Experiment.SENS
            
        case Experiment.OPTI
            
    end
end


function button6_callback(hObject, callbackdata)
% Saves experiment


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
        inspectionFaculty = selectedExp.returnItemSetting(ItemSetting.STRATS_INSP);
        penaltyFaculty = selectedExp.returnItemSetting(ItemSetting.PEN_POLICY);
        volMaintFaculty = selectedExp.returnItemSetting(ItemSetting.STRATS_VOL_MAINT);
        mandMaintFaculty = selectedExp.returnItemSetting(ItemSetting.STRATS_MAND_MAINT);
        
        description = cell(1,0);
        
        description{end+1} = ['Type of experiment:  ', typeExp];
        description{end+1} = [''];
        description{end+1} = ['Realizations per game:  ', num2str(numRlz)];
        description{end+1} = [''];
        description{end+1} = ['Inspection strategy: ', inspectionFaculty.selectedStrategy.id];
        description{end+1} = ['Penalty strategy: ', penaltyFaculty.selectedStrategy.id];
        description{end+1} = ['Vol maint strategy: ', volMaintFaculty.selectedStrategy.id];
        description{end+1} = ['Mand maint strategy: ', mandMaintFaculty.selectedStrategy.id];
        
        htext2.String = description;
    else
        rmappdata(hpanel2, 'current_progsettings');
        htext2.String = 'No experiment has been selected.';
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
    p = findobj('Tag','progresspatch');
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
    
    deleteChildHandles(hpanel4);
    
    layout_common()
    
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
        'Callback', @gui.plotRealization, ...
        'TooltipString', sprintf('Shows figure with interaction of players\nand the evolution of the infrastructure system'), ...
        'Tag', 'button4');

    data = getappdata(hpanel4, 'reportSingle');

    text3 = uicontrol(  hpanel4_1,...
        'Style','text',...
        'FontSize', 10, ...
        'String','Ua',...
        'Position',[20 50 60 18], ...
        'Tag', 'text3');
    
    text4 = uicontrol(  hpanel4_1,...
        'Style','text',...
        'FontSize', 10, ...
        'String','Up',...
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
    
    hpanel4 = findobj('Tag', 'panel4');
    
    deleteChildHandles(hpanel4);
    
    layout_common()
    
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
        'String', 'Utility disp.',...
        'Position', [20 15 80 30],...
        'Callback', @gui.plotAggregateDisp, ...
        'TooltipString', sprintf('Shows figure with dispersion of utilities\nand a histogram of each.'), ...
        'Tag', 'button4');

    data = getappdata(hpanel4, 'reportDispersion');
    
    mean_ua = mean(data.ua);
    mean_up = mean(data.up);
    
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
        'String', num2str(mean_ua),...
        'Position',[100 50 120 18], ...
        'Tag', 'text5');
    
    text4 = uicontrol(  hpanel4_1,...
        'Style','text',...
        'Background', 'white', ...
        'FontSize', 10, ...
        'String', num2str(mean_up),...
        'Position',[100 20 120 18], ...
        'Tag', 'text6');

end


function layout_SENS()
end


function layout_OPTI()
end

function layout_common()
    
    hpanel4 = findobj('Tag', 'panel4');
    
    hpanel4_3 = uipanel(hpanel4, ...
        'Title', 'Export', ...
        'Units', 'pixels', ...
        'Position', [660 20 180 115], ...
        'Tag', 'panel4_3');
    
    button6 = uicontrol(hpanel4_3, ...
        'Style', 'pushbutton', ...
        'String', 'Save .mat', ...
        'Position', [20 15 80 30], ...
        'Callback', @gui.saveMat );
    
    
        
end


function remove_programsettings()
% Removes program settings app data

    hpanel2 = findobj('Tag', 'panel2');
    
    % Program settings
    if isappdata(hpanel2, 'array_progsettings')
        rmappdata(hpanel2, 'array_progsettings');
    end
end

function remove_experiment()
% Removes experiment app data

    hpanel3 = findobj('Tag', 'panel3');
    
    % Experiment
    if isappdata(hpanel3, 'experiment')
        rmappdata(hpanel3, 'experiment');
    end
end

function remove_reports()
% Removes reports app data

    hpanel4 = findobj('Tag', 'panel4');
    
    % Report single
    if isappdata(hpanel4, 'reportSingle')
        rmappdata(hpanel4, 'reportSingle');
    end
    
    % Report dispersion
    if isappdata(hpanel4, 'reportDispersion')
        rmappdata(hpanel4, 'reportDispersion');
    end
end