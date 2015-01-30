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
progSettings = experiments.ex7.settings();
experim = Experiment(progSettings);
experim.run()
experim.report()