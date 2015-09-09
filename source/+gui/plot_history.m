function plot_history(panel, data)
% Show the history of a SING experiment

import dataComponents.Event

horiz_margin = 0.05;
vert_margin = 0.05;

height = (1-4*vert_margin)/3;
width = 0.85;

% Colors
boxColor = [0.35  0.35  0.35];
default_blue = [0 0.4470 0.7410];
grey = [0.25 0.25 0.25];
cyan_low = [0 0.9 0.9];

posVec1 = [0.1    0.685    width   height];
posVec2 = [0.1    0.375      width   height];
posVec3 = [0.1    0.07                 width   height];

ax1 = subplot('Position', posVec1, ...
    'Parent', panel, 'Tag', 'deg_history');
ax2 = subplot('Position', posVec2, ...
    'Parent', panel, 'Tag', 'balance_history');
ax3 = subplot('Position', posVec3, ...
    'Parent', panel, 'Tag', 'perf_history');

% Figure 1. Interaction sequence

width_fig1 = 700;       % pixels
height_fig1 = 400;      % pixels

%% ---------:::::::::::::::: Subfigure 1 ::::::::::::::::---------------

%   ::::--> Degradation path

finalTimePlot = (1+0.05)*data.getValue('contractDuration');

set(ax1, ...
    'XLim', [0, finalTimePlot], ...
    'YLim', [data.getValue('nullPerf'), data.getValue('maxPerf')],...
    'FontSize', 8, ...
    'Color', 'white', ...
    'Box', 'on', ...
    'XColor', boxColor,...
    'YColor', boxColor, ...
    'XTickLabel', [], ...
    'Tag', 'deg_path');

hold(ax1, 'on')
grid(ax1, 'off');

hLine1 = plot(ax1, data.getValue('perfHistory').time, data.getValue('perfHistory').value);
hLine2 = plot(ax1, [0, finalTimePlot], [data.getValue('threshold'), data.getValue('threshold')],':', ...
    'Color',[0.7 0 0], ...
    'LineWidth', 0.1);

ylabel(ax1, 'Performance level')

%   ::::--> Events markers

% Inspections Only
if ~isempty(data.getValue('inspectionMarker'))
    hLine3 = plot(ax1, ...
        data.getValue('inspectionMarker').time, data.getValue('inspectionMarker').value, 'o', ...
        'MarkerEdgeColor','black', ...
        'MarkerSize', 6);
end

% Detections
if ~isempty(data.getValue('detectionMarker'))
    hLine4 = plot(ax1, ...
        data.getValue('detectionMarker').time, data.getValue('detectionMarker').value, 'd', ...
        'MarkerEdgeColor','red', ...
        'MarkerSize', 8);
end

% Maintenances
if ~isempty(data.getValue('volMaintMarker'))
    hLine5 = plot(ax1, ...
        data.getValue('volMaintMarker').time, data.getValue('volMaintMarker').value,'+', ...
        'MarkerEdgeColor',[13 209 62]/255, ...
        'MarkerFaceColor','green', ...
        'MarkerSize', 4);
end

% Shocks
if ~isempty(data.getValue('shockMarker'))
    hLine6 = plot(ax1, ...
        data.getValue('shockMarker').time, data.getValue('shockMarker').value,'x', ...
        'MarkerEdgeColor','magenta', ...
        'MarkerSize', 7);
end

hold(ax1, 'off')

%% ---------:::::::::::::::: Subfigure 2 ::::::::::::::::---------------

%set(gcf, 'CurrentHandle', ax2);

[ax2_yy, h1, h2] = plotyy(ax2, ...
    data.getValue('balA').time, data.getValue('balA').balance, ...
    data.getValue('balP').time, data.getValue('balP').balance);

set(ax2_yy(1), ...
    'XLim', [0 finalTimePlot], ...
    'FontSize', 8, ...
    'Color', 'white', ...
    'Box', 'on', ...
    'XColor', boxColor,...
    'GridColor', [0.15 0.15 0.15], ...
    'XTickLabel', []);

set(ax2_yy(2), ...
    'XLim', [0 finalTimePlot], ...
    'FontSize', 8, ...
    'XColor', boxColor,...
    'GridColor', [0.15 0.15 0.15], ...
    'XTickLabel', []);

hold(ax2_yy(1), 'on')

% Contributions - Agent
if ~isempty(data.getValue('jumpsContrib_agent'))
    plot(ax2_yy(1), data.getValue('jumpsContrib_agent').time, data.getValue('jumpsContrib_agent').balance, 'o', 'MarkerSize', 3, 'MarkerEdgeColor','blue', 'MarkerFaceColor', 'blue');
end

% Maintenance - Agent
if ~isempty(data.getValue('jumpsMaint_agent'))
    plot(ax2_yy(1), data.getValue('jumpsMaint_agent').time, data.getValue('jumpsMaint_agent').balance, 'o', 'MarkerSize', 3, 'MarkerEdgeColor','green',  'MarkerFaceColor', 'green');
end

% Penalties - Agent
if ~isempty(data.getValue('jumpsPenalties_agent'))
    plot(ax2_yy(1), data.getValue('jumpsPenalties_agent').time, data.getValue('jumpsPenalties_agent').balance, 'o', 'MarkerSize', 3, 'MarkerEdgeColor','red',  'MarkerFaceColor', 'red');
end

hold(ax2_yy(2), 'on')

% Inspections - Principal
if ~isempty(data.getValue('jumpsInspections_principal'))
    plot(ax2_yy(2), data.getValue('jumpsInspections_principal').time, data.getValue('jumpsInspections_principal').balance, 'o', 'MarkerSize', 3, 'MarkerEdgeColor', grey,  'MarkerFaceColor', grey);
end

%{
% Contributions - Principal
if ~isempty(data.getValue('jumpsContrib_principal'))
    plot(ax2_yy(2), data.getValue('jumpsContrib_principal').time, data.getValue('jumpsContrib_principal').balance, 'o', 'MarkerSize', 3, 'MarkerEdgeColor', cyan_low,  'MarkerFaceColor', cyan_low);
end

% Penalties - Principal
if ~isempty(data.getValue('jumpsPenalties_principal'))
    plot(ax2_yy(2), data.getValue('jumpsPenalties_principal').time, data.getValue('jumpsPenalties_principal').balance, 'o', 'MarkerSize', 3, 'MarkerEdgeColor', 'red',  'MarkerFaceColor', 'red');
end
%}

%legend(ax2,'Discrete flow', 'Location', 'bestoutside')
ylabel(ax2_yy(1), 'Monetary balance ($)', 'Color', boxColor)
grid(ax2, 'on');

%% ---------:::::::::::::::: Subfigure 3 ::::::::::::::::---------------

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
    data.getValue('perceivedPerfMeanValue').time, ...
    data.getValue('perceivedPerfMeanValue').meanvalue, ...
    '-ok', ...
    'MarkerSize', 3, ...
    'MarkerFaceColor', grey);

plot(ax3, ...
    data.getValue('realPerfMeanValue').time, ...
    data.getValue('realPerfMeanValue').meanvalue, ...
    '-.');

%legend(ax3, 'Perceived','Real', 'Location', 'bestoutside')

xlabel(ax3, 'Time')
ylabel(ax3, 'Mean performance')


% Synchronize axes limits
linkaxes([ax1,ax2_yy(1),ax2_yy(2),ax3],'x')

end