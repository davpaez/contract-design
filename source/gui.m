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
    heightWindow = 500;
    
    gui_State.window_props.wh = [widthWindow, heightWindow];
    
    %% Main window
    posVec = [  (widthScreen/2)-(widthWindow/2) , ...
                (heightScreen/2)-(heightWindow/2) , ...
                widthWindow , ...
                heightWindow];

    hMainFigure = figure( 'MenuBar','none',...
                          'Toolbar','none',...
                          'Units', 'pixels', ...
                          'Position', posVec,...
                          'Visible','off');
    
    guidata(hMainFigure, gui_State);
    
    hMainFigure.Visible = 'on';
    
    %% Tabs
    margin = 20;
    tabGroup_posVec = [ margin, ...
                        margin, ...
                        (widthWindow-2*margin), ...
                        (heightWindow-2*margin)];
                    
    tabgp = uitabgroup(hMainFigure, 'Units', 'pixels', ...
                                    'Position', tabGroup_posVec, ...
                                    'Tag', 'tabgroup');
    
    tab1 = uitab(tabgp,'Title','Experiment', ...
                        'Tag', 'tab1');
    tab2 = uitab(tabgp,'Title','Results', ...
                        'Tag', 'tab2');
    
    %% Panels
    
    % Panels for tab1
    width_panels = 815;
    
    panel1 = uipanel(tab1,  'Title', 'Select experiments folder', ...
                            'Units', 'pixels', ...
                            'Position', [20 350 width_panels 70], ...
                            'Tag', 'panel1');
    
    panel2 = uipanel(tab1,  'Title', 'Choose experiment', ...
                            'Units', 'pixels', ...
                            'Position', [20 110 width_panels 230], ...
                            'Tag', 'panel2');
    
    panel3 = uipanel(tab1,  'Title', 'Run experiment', ...
                            'Units', 'pixels', ...
                            'Position', [20 20 width_panels 80], ...
                            'Tag', 'panel3');
    
    panel4 = uipanel(tab2,  'Title', 'Overview', ...
                            'Units', 'pixels', ...
                            'Position', [20 300 width_panels 120], ...
                            'Tag', 'panel4');
    % Panels for tab2
    
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
                        'String', 'Run experiment', ...
                        'Position', [20 15 150 30],...
                        'Callback', @button3_callback, ...
                        'Tag', 'button3');

    %% Static text
    
    text1 = uicontrol(  panel1,...
                        'Style','text',...
                        'BackgroundColor', 'white', ...
                        'FontSize', 10, ...
                        'String','',...
                        'Position',[120 20 670 18], ...
                        'Tag', 'text1');
    
    text2 = uicontrol(panel2, ...
                        'Style','text',...
                        'BackgroundColor', 'white', ...
                        'FontSize', 10, ...
                        'String','No experiment has been selected.',...
                        'HorizontalAlignment', 'left', ...
                        'Position',[350 20 440 180], ...
                        'Tag', 'text2');
                    
    text3 = uicontrol(panel4, ...
                        'Style','text',...
                        'BackgroundColor', 'white', ...
                        'FontSize', 10, ...
                        'String','No experiment has been selected.',...
                        'HorizontalAlignment', 'left', ...
                        'Position',[350 20 440 180], ...
                        'Tag', 'text3');
    
    
    
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
                'Position', [190 20 600 10], ...
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
    
    %% Axes
    
%     ax2 = axes( 'Units', 'pixels', ...
%                 'Position', [190 20 600 10], ...
%                 'XLim',[0 1], ...
%                 'YLim',[0 1],...
%                 'Color','white',...
%                 'Box', 'on', ...
%                 'XColor', [0.4314  0.4314  0.4314],...
%                 'YColor', [0.4314  0.4314  0.4314],...
%                 'Parent', panel4);
    
    %% Finilize window setup
    
    hMainFigure.Visible = 'on';
    
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
