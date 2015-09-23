function plot_dispersion(panel, data, kw)

assert(length(kw) == 2, 'Two keywords must be passed within kw argument')

ax1 = subplot('Position', [0.1 0.8 0.7 0.15], 'Parent', panel);
ax2 = subplot('Position', [0.1 0.1 0.7 0.65], 'Parent', panel);
ax3 = subplot('Position', [0.85 0.1 0.1 0.65], 'Parent', panel);

nbins = 25;

x_data = data.getEntry(kw{1});
y_data = data.getEntry(kw{2});

x_vector = x_data.value;
y_vector = y_data.value;

histogram(ax1, x_vector, nbins);
histogram(ax3, y_vector, nbins);
view(90,-90)

scatter(ax2, x_vector, y_vector)

set(ax1, ...
    'Color', panel.BackgroundColor, ...
    'XTick',[], ...
    'Box', 'off', ...
    'XColor', [0.4314  0.4314  0.4314],...
    'YColor', [0.4314  0.4314  0.4314])

set(ax3, ...
    'Color', panel.BackgroundColor, ...
    'Box', 'off', ...
    'XTick',[], ...
    'XColor', [0.4314  0.4314  0.4314],...
    'YColor', [0.4314  0.4314  0.4314])

set(ax2, ...
    'XColor', [0.4314  0.4314  0.4314],...
    'YColor', [0.4314  0.4314  0.4314])

ax2.YLim = ax3.XLim;
ax2.XLim = ax1.XLim;

xlabel(ax2, x_data.description)
ylabel(ax2, y_data.description)

% Plot lines for mean values

hold(ax2, 'on')

mean_ua = x_data.mean;
mean_up = y_data.mean;

plot(ax2, [min(ax2.XLim), max(ax2.XLim)], [mean_up, mean_up],':', ...
    'Color',[0.7 0 0], ...
    'LineWidth', 0.1)

plot(ax2, [mean_ua, mean_ua], [min(ax2.YLim), max(ax2.YLim)], ':', ...
    'Color',[0.7 0 0], ...
    'LineWidth', 0.1)

end

