function plot_dispersion(panel, data)

hFigure = figure('Visible', 'off');

ax1 = subplot('Position', [0.1 0.8 0.7 0.15]);
ax2 = subplot('Position', [0.1 0.1 0.7 0.65]);
ax3 = subplot('Position', [0.85 0.1 0.1 0.65]);

hpanel4 = findobj('Tag', 'panel4');
data = getappdata(hpanel4, 'reportDispersion');

nbins = 25;

histogram(ax1, data.ua, nbins);
histogram(ax3, data.up, nbins);
view(90,-90)

scatter(ax2, data.ua, data.up)

set(ax1, ...
    'Color', hFigure.Color, ...
    'XTick',[], ...
    'Box', 'off', ...
    'XColor', [0.4314  0.4314  0.4314],...
    'YColor', [0.4314  0.4314  0.4314])

set(ax3, ...
    'Color', hFigure.Color, ...
    'XTick',[], ...
    'Box', 'off', ...
    'XColor', [0.4314  0.4314  0.4314],...
    'YColor', [0.4314  0.4314  0.4314])

set(ax2, ...
    'XColor', [0.4314  0.4314  0.4314],...
    'YColor', [0.4314  0.4314  0.4314])

xlabel(ax2, 'Agent''s utility')
ylabel(ax2, 'Principal''s utility')

hold(ax2, 'on')

mean_ua = mean(data.ua);
mean_up = mean(data.up);

plot(ax2, [min(ax2.XLim), max(ax2.XLim)], [mean_up, mean_up],':', ...
    'Color',[0.7 0 0], ...
    'LineWidth', 0.1)

plot(ax2, [mean_ua, mean_ua], [min(ax2.YLim), max(ax2.YLim)], ':', ...
    'Color',[0.7 0 0], ...
    'LineWidth', 0.1)

hFigure.Visible = 'on';

end

