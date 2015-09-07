function report_dispersion()
    
    hpanel4 = findobj('Tag', 'panel4');
    data = getappdata(hpanel4, 'reportDispersion');
    
    hFigure = figure( 'Name', 'Dispersion report', ...
        'NumberTitle', 'off', ...
        'MenuBar','none',...
        'Toolbar','figure',...
        'Units', 'pixels', ...
        'Position', [100 100 1200 800],...
        'Resize', 'off', ...
        'Visible','off', ...
        'Tag', 'Disp_window');
    
    panel7 = uipanel(hFigure, 'Title', 'Utility dispersion', ...
        'Units', 'pixels', ...
        'Position', [20 20 530 500], ...
        'Tag', 'panel7');
    
    panel8 = uipanel(hFigure, 'Title', 'Selected realization', ...
        'Units', 'pixels', ...
        'Position', [565 20 615 501], ...
        'Tag', 'panel8');
    
    button7 = uicontrol(hFigure, ...
        'Style', 'pushbutton', ...
        'String', 'Prev.',...
        'Position', [790 540 80 30],...
        'Callback', @button7_callback, ... 
        'Tag', 'button7');
    
    button8 = uicontrol(hFigure, ...
        'Style', 'pushbutton', ...
        'String', 'Next',...
        'Position', [870 540 80 30],...
        'Callback', @button8_callback, ...
        'Tag', 'button8');
    
    button9 = uicontrol(hFigure, ...
        'Style', 'pushbutton', ...
        'String', 'Go',...
        'Position', [600 540 80 30],...
        'Callback', @button9_callback, ...
        'Tag', 'button9');

    gui.plot_dispersion(panel7, data)
    data_rlz = data.getValue('data_rlz');
    
    num_exp = [' / ', num2str(length(data_rlz))];
    
    
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
    
    gui.plot_history(panel8, data_rlz{1})
    
    hFigure.Visible = 'on';

end

function button7_callback(hObject, callbackdata)
% Previous button

disp_window = findobj('Tag', 'Disp_window');
data_rlz = getappdata(disp_window, 'data_rlz');
hpanel8 = findobj('Tag', 'panel8');

gui.deleteChildHandles(hpanel8)

current_rlz = getappdata(disp_window, 'current_rlz');

if current_rlz > 1
    setappdata(disp_window, 'current_rlz', current_rlz-1);
end

% Update
update_rlz_plot(disp_window, hpanel8);

end

function button8_callback(hObject, callbackdata)
% Next button

disp_window = findobj('Tag', 'Disp_window');
data_rlz = getappdata(disp_window, 'data_rlz');
hpanel8 = findobj('Tag', 'panel8');


n = length(data_rlz);
current_rlz = getappdata(disp_window, 'current_rlz');

if current_rlz < n
    setappdata(disp_window, 'current_rlz', current_rlz+1);
end

% Update
update_rlz_plot(disp_window, hpanel8);

end

function button9_callback(hObject, callbackdata)
% Go button

htext4= findobj('Tag', 'text4');
selected_rlz = str2num(htext4.String);

disp_window = findobj('Tag', 'Disp_window');
data_rlz = getappdata(disp_window, 'data_rlz');
hpanel8 = findobj('Tag', 'panel8');

n = length(data_rlz);

if 1 <= selected_rlz && selected_rlz <= n
    setappdata(disp_window, 'current_rlz', selected_rlz);
    update_rlz_plot(disp_window, hpanel8);
end

end

function update_rlz_plot(hFigure, panel)

% Delete child handles
gui.deleteChildHandles(panel)

% Get needed vars
data_rlz = getappdata(hFigure, 'data_rlz');
current_rlz = getappdata(hFigure, 'current_rlz');

% Update edit text field
htext4 = findobj('Tag', 'text4');
htext4.String = num2str(current_rlz);

% Update plot
gui.plot_history(panel, data_rlz{current_rlz})

end