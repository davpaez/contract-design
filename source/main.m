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
progSettings = ex6.settings();
experim = Experiment(progSettings);
experim.run()
%experim.report()