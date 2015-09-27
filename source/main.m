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

% Experiment 2
progSettings = ex2.settings();
experim = Experiment(progSettings);

experim.run();
data2 = experim.report();

%%

% Experiment 3
progSettings = ex3.settings();
experim = Experiment(progSettings);

experim.run();
data3 = experim.report();

%%

% Experiment 4
progSettings = ex4.settings();
experim = Experiment(progSettings);

experim.run();
data4 = experim.report();

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

% Saving data

save data1.mat data1
save data2.mat data2
save data3.mat data3
save data4.mat data4
save data5.mat data5
save data6.mat data6

%%

% Loading data

clear all
clc

load data1.mat
load data2.mat
load data3.mat
load data4.mat
load data5.mat
load data6.mat

%%

% Plotting Experiment 1

h1 = figure('Units', 'pixels', ...
    'Position', [300 300 414 257],...
    'Resize', 'on', ...
    'Visible','on', ...
    'Name', 'Experiment 1', ...
    'Tag', 'exp1');
p1 = uipanel(h1);
gui.plot_history(p1, data1)


%%

% Plotting Experiment 2

h6_SING = figure('Units', 'pixels', ...
    'Position', [300 300 443 178],...
    'Resize', 'on', ...
    'Visible','on', ...
    'Name', 'Experiment 2', ...
    'Tag', 'exp2');
p2 = uipanel(h6_SING);
gui.plot_history(p2, data2)

%%

% Plotting Experiment 3

h3 = figure('Units', 'pixels', ...
    'Position', [300 300 443 178],...
    'Resize', 'on', ...
    'Visible','on', ...
    'Name', 'Experiment 3', ...
    'Tag', 'exp3');
p3 = uipanel(h3);
gui.plot_history(p3, data3)

%%

% Plotting Experiment 4

h4 = figure('Units', 'pixels', ...
    'Position', [300 300 443 178],...
    'Resize', 'on', ...
    'Visible','on', ...
    'Name', 'Experiment 4', ...
    'Tag', 'exp4');
p4 = uipanel(h4);
gui.plot_history(p4, data4)

%%

% Plotting Experiment 5 - Single realization

h6_SING = figure('Units', 'pixels', ...
    'Position', [300 300 443 178],...
    'Resize', 'on', ...
    'Visible','on', ...
    'Name', 'Experiment 5 - SING', ...
    'Tag', 'exp5_SING');
p6_SING = uipanel(h6_SING);
gui.plot_history(p6_SING, data5.source{1})


%%

% Plotting Experiment 6 - Single realization

h6_SING = figure('Units', 'pixels', ...
    'Position', [300 300 443 178],...
    'Resize', 'on', ...
    'Visible','on', ...
    'Name', 'Experiment 6 - SING', ...
    'Tag', 'exp6_SING');
p6_SING = uipanel(h6_SING);
gui.plot_history(p6_SING, data6.source{1})

%%

% Plotting scatter ua vs. up from experiments 5 and 6


h56 = figure('Units', 'pixels', ...
    'Position', [300 300 450 400],...
    'Resize', 'on', ...
    'Visible','on', ...
    'Name', 'Comparison Exp 5 and Exp 6', ...
    'Tag', 'exp56');

p56 = uipanel(h56);
gui.plot_dispersion_comparison(p56, data5, data6, {'ua', 'up'});
