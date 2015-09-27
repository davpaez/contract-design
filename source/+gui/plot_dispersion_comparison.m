function plot_dispersion_comparison( panel, data1, data2, kw )

assert(length(kw) == 2, 'Two keywords must be passed within kw argument')

%% Axes

% Axis - Histogram X
ax1 = subplot('Position', [0.1 0.85 0.55 0.10], 'Parent', panel);

% Axis - Data 1
ax2 = subplot('Position', [0.1 0.70 0.55 0.10], 'Parent', panel);

% Axis - Scatter
ax3 = subplot('Position', [0.1 0.1 0.55 0.55], 'Parent', panel);

% Axis - Data1
ax4 = subplot('Position', [0.70 0.1 0.1 0.55], 'Parent', panel);

% Axis - Data2
ax5 = subplot('Position', [0.85 0.1 0.1 0.55], 'Parent', panel);

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
hold(ax3,'on')
scatter(ax3, x1_vector, y1_vector, 'o') % Data 1
scatter(ax3, x2_vector, y2_vector, '+') % Data 2

x_lim = ax3.XLim;
y_lim = ax3.YLim;

x_bin_width = diff(x_lim)/30;
y_bin_width = diff(y_lim)/30;

% Histograms X

hold(ax1, 'on')
h1 = histogram(ax1, x2_vector);
h2 = histogram(ax1, x1_vector);

h1.Normalization = 'probability';
h1.BinWidth = x_bin_width;
h2.Normalization = 'probability';
h2.BinWidth = x_bin_width;

ax1.XLim = x_lim;
ax2.XLim = x_lim;

% Histograms Y

histogram(ax4, y1_vector, nbins);
histogram(ax5, y2_vector, nbins);

view(ax4, 90, -90)
view(ax5, 90, -90)

ax4.XLim = y_lim;
ax5.XLim = y_lim;

end

