function plot_history(panel, data)
% Show the history of a SING experiment

import dataComponents.Event

%hpanel4 = findobj('Tag', 'panel4');

%data = getappdata(hpanel4, 'reportSingle');

horiz_margin = 0.05;
vert_margin = 0.05;

height = (1-4*vert_margin)/3;
width = 0.85;

boxColor = [0.35  0.35  0.35];

posVec1 = [0.1    0.685    width   height];
posVec2 = [0.1    0.375      width   height];
posVec3 = [0.1    0.07                 width   height];

ax1 = subplot('Position', posVec1, ...
    'Parent', panel);
ax2 = subplot('Position', posVec2, ...
    'Parent', panel);
ax3 = subplot('Position', posVec3, ...
    'Parent', panel);

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
plot(ax2, data.jumpsContrib.time, data.jumpsContrib.balance, 'o', 'MarkerSize', 3, 'MarkerEdgeColor','g', 'MarkerFaceColor', 'g');
plot(ax2, data.jumpsMaint.time, data.jumpsMaint.balance, 'o', 'MarkerSize', 3, 'MarkerEdgeColor','r',  'MarkerFaceColor', 'r');


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
    data.perceivedPerfMeanValue.time, data.perceivedPerfMeanValue.meanvalue, '-o', ...
    data.realPerfMeanValue.time, data.realPerfMeanValue.meanvalue,'-.');


%plot(perfHistory.time,perfHistory.value, 'Color', [0.9 0.9 0.9])

%legend(ax3, 'Perceived','Real', 'Location', 'bestoutside')

xlabel(ax3, 'Time')
ylabel(ax3, 'Mean performance')


% Synchronize axes limits
linkaxes([ax1,ax2,ax3],'x')

end