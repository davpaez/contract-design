function plot_dispersion_comparison( panel, data1, data2, kw )

assert(length(kw) == 2, 'Two keywords must be passed within kw argument')

%% Axes

% Axis - Histogram X
ax1 = subplot('Position', [0.1 0.85 0.70 0.10], 'Parent', panel);

% Axis - Scatter
ax2 = subplot('Position', [0.1 0.1 0.70 0.70], 'Parent', panel);

% Axis - Histogram Y
ax3 = subplot('Position', [0.85 0.1 0.1 0.70], 'Parent', panel);

%% Data

nbins = 30;

x1_data = data1.getEntry(kw{1});
y1_data = data1.getEntry(kw{2});
x1_vector = x1_data.value;
y1_vector = y1_data.value;

x2_data = data2.getEntry(kw{1});
y2_data = data2.getEntry(kw{2});
x2_vector = x2_data.value;
y2_vector = y2_data.value;


% Scatter
hold(ax2,'on')
scatter(ax2, x1_vector, y1_vector, 'o') % Data 1
scatter(ax2, x2_vector, y2_vector, '+') % Data 2

x_lim = ax2.XLim;
y_lim = ax2.YLim;

x_bin_width = diff(x_lim)/nbins;
y_bin_width = diff(y_lim)/nbins;

% Histograms X

hold(ax1, 'on')
hist1 = histogram(ax1, x1_vector);
hist2 = histogram(ax1, x2_vector);

hist1.Normalization = 'probability';
hist1.BinWidth = x_bin_width;
hist2.Normalization = 'probability';
hist2.BinWidth = x_bin_width;

ax1.XLim = x_lim;

% Histograms Y

hold(ax3, 'on')
hist3 = histogram(ax3, y1_vector);
hist4 = histogram(ax3, y2_vector);

view(ax3, 90, -90)

hist3.Normalization = 'probability';
hist3.BinWidth = y_bin_width;
hist4.Normalization = 'probability';
hist4.BinWidth = y_bin_width;

ax3.XLim = y_lim;

% Styling

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

% Labels

xlabel(ax2, x1_data.description)
ylabel(ax2, y1_data.description)
end

