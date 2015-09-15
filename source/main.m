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
progSettings = ex4.settings();
experim = Experiment(progSettings);

experim.run();
data = experim.report();

ua = data.getValue('ua_vector');
up = data.getValue('up_vector');
scatter(ua, up)