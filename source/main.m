% Main script

%% Initialization
clear all
close all
clc

% Import packages
import entities.*
import dataComponents.*
import managers.*

% Load program settings
addpath('experiments');

%%

% Experiment 1
progSettings = ex1.settings();
experim = Experiment(progSettings);

experim.run();
data1 = experim.report();


%%

% Experiment 5
progSettings = ex5.settings();
experim = Experiment(progSettings);

experim.run();
data5 = experim.report();

%%


% Experiment 6
progSettings = ex6.settings();
experim = Experiment(progSettings);

experim.run();
data6 = experim.report();

%% 


xdata_exp5 = data5.getEntry('ua');
ydata_exp5 = data5.getEntry('up');

xdata_exp6 = data6.getEntry('ua');
ydata_exp6 = data6.getEntry('up');

% h = figure('Units', 'pixels', ...
%     'Position', [300 300 500 200],...
%     'Resize', 'on', ...
%     'Visible','on', ...
%     'Tag', 'main');
% 
% gui.plot_dispersion(h, data5, {'ua', 'up'});
% hold(h, 'on')
% gui.plot_dispersion(h, data6, {'ua', 'up'});

scatter(xdata_exp5.value, ydata_exp5.value, 'o')
hold on
scatter(xdata_exp6.value, ydata_exp6.value,'+')
xlabel('Agent''s utility')
ylabel('Principal''s utility')

h1 = figure;
gui.plot_dispersion(h1, data6, {'ua', 'up'});
