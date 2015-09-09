function report_dispersion()
    
    hpanel4 = findobj('Tag', 'panel4');
    data_disp = getappdata(hpanel4, 'reportDispersion');
    
    hFigure = figure( 'Name', 'Dispersion report', ...
        'NumberTitle', 'off', ...
        'MenuBar','none',...
        'Toolbar','figure',...
        'Units', 'pixels', ...
        'Position', [100 100 1200 800],...
        'Resize', 'off', ...
        'Visible','off', ...
        'Tag', 'Disp_window');
    
    %% Panels
    
    panel7 = uipanel(hFigure, 'Title', 'Utility dispersion', ...
        'Units', 'pixels', ...
        'Position', [20 530 530 250], ...
        'Tag', 'panel7');
    
    panel8 = uipanel(hFigure, 'Title', 'Selected realization', ...
        'Units', 'pixels', ...
        'Position', [565 580 615 200], ...
        'Tag', 'panel8');
    
    panel9 = uipanel(hFigure, 'Title', 'Utility dispersion', ...
        'Units', 'pixels', ...
        'Position', [20 20 530 500], ...
        'Tag', 'panel9');
    
    panel10 = uipanel(hFigure, 'Title', 'Selected realization', ...
        'Units', 'pixels', ...
        'Position', [565 20 615 500], ...
        'Tag', 'panel10');
    
    %% Buttons
    
    button7 = uicontrol(panel7, ...
        'Style', 'pushbutton', ...
        'String', 'Plot',...
        'Position', [20 20 80 30],...
        'Callback', @button7_callback, ... 
        'Tag', 'button10');
    
    button8 = uicontrol(hFigure, ...
        'Style', 'pushbutton', ...
        'String', 'Go',...
        'Position', [600 540 80 30],...
        'Callback', @button8_callback, ...
        'Tag', 'button9');
    
    button9 = uicontrol(hFigure, ...
        'Style', 'pushbutton', ...
        'String', 'Prev.',...
        'Position', [790 540 80 30],...
        'Callback', @button9_callback, ... 
        'Tag', 'button7');
    
    button10 = uicontrol(hFigure, ...
        'Style', 'pushbutton', ...
        'String', 'Next',...
        'Position', [870 540 80 30],...
        'Callback', @button10_callback, ...
        'Tag', 'button8');
    

    
    kw = {'ua', 'up'};
    gui.plot_dispersion(panel9, data_disp, kw);
    
    data_rlz = data_disp.source;
    num_exp = [' / ', num2str(length(data_rlz))];
    
    %% Text
    
    text3 = uicontrol(hFigure,...
        'Style','text',...
        'BackgroundColor', hFigure.Color, ...
        'FontSize', 10, ...
        'String',num_exp,...
        'Position',[735 545 40 18], ...
        'Tag', 'text3');
    
    text4 = uicontrol(hFigure,...
        'Style','edit',...
        'BackgroundColor', 'white', ...
        'FontSize', 10, ...
        'String', '1',...
        'Position',[700 545 30 18], ...
        'Tag', 'text4');
    
    setappdata(hFigure, 'data_rlz', data_rlz);
    
    current_rlz = 1;
    setappdata(hFigure, 'current_rlz', current_rlz);
    
    gui.plot_history(panel10, data_rlz{1});
    gui.create_table_single(panel8, data_rlz{1});
    gui.create_table_dispersion(panel7, data_disp);
    
    hFigure.Visible = 'on';

end

function button7_callback(hObject, callbackdata)
% Plot button

hpanel7 = findobj('Tag', 'panel7');
kw = getappdata(hpanel7, 'kw');
n = length(kw);

if n > 0

    hpanel4 = findobj('Tag', 'panel4');
    data_disp = getappdata(hpanel4, 'reportDispersion');
    
    hpanel9 = findobj('Tag', 'panel9');
    gui.deleteChildHandles(hpanel9);
    
    if n < 2
        gui.plot_histogram()
    else
        gui.plot_dispersion(hpanel9, data_disp, kw);
    end
end

end

function button8_callback(hObject, callbackdata)
% Go button

htext4= findobj('Tag', 'text4');
selected_rlz = str2num(htext4.String);

disp_window = findobj('Tag', 'Disp_window');
data_rlz = getappdata(disp_window, 'data_rlz');
hpanel10 = findobj('Tag', 'panel10');
hpanel8 = findobj('Tag', 'panel8');

n = length(data_rlz);

if 1 <= selected_rlz && selected_rlz <= n
    setappdata(disp_window, 'current_rlz', selected_rlz);
    update_rlz_plot(disp_window, hpanel10, hpanel8);
end

end

function button9_callback(hObject, callbackdata)
% Previous button

disp_window = findobj('Tag', 'Disp_window');
hpanel10 = findobj('Tag', 'panel10');
hpanel8 = findobj('Tag', 'panel8');

gui.deleteChildHandles(hpanel10)

current_rlz = getappdata(disp_window, 'current_rlz');

if current_rlz > 1
    setappdata(disp_window, 'current_rlz', current_rlz-1);
end

% Update
update_rlz_plot(disp_window, hpanel10, hpanel8);

end

function button10_callback(hObject, callbackdata)
% Next button

disp_window = findobj('Tag', 'Disp_window');
data_rlz = getappdata(disp_window, 'data_rlz');
hpanel10 = findobj('Tag', 'panel10');
hpanel8 = findobj('Tag', 'panel8');

n = length(data_rlz);
current_rlz = getappdata(disp_window, 'current_rlz');

if current_rlz < n
    setappdata(disp_window, 'current_rlz', current_rlz+1);
end

% Update
update_rlz_plot(disp_window, hpanel10, hpanel8);

end

function update_rlz_plot(hFigure, panel_plots, panel_table)

% Delete child handles
gui.deleteChildHandles(panel_plots)
gui.deleteChildHandles(panel_table)

% Get needed vars
data_rlz = getappdata(hFigure, 'data_rlz');
current_rlz = getappdata(hFigure, 'current_rlz');

% Update edit text field
htext4 = findobj('Tag', 'text4');
htext4.String = num2str(current_rlz);

% Update table
gui.create_table_single(panel_table, data_rlz{current_rlz});

% Update plot
gui.plot_history(panel_plots, data_rlz{current_rlz})

end