%% Similarity Analysis for Time Series Data
% This script performs analysis of different similarity measures using
% Acceleration/Gyroscope signal data. 
% It includes data preparation, various signal processing
% techniques (Wavelet Analysis, Windowed Cross-Correlation, Windowed Dynamic Time Warping),
% and prepares data for subsequent classification.
% 
% Author: Yanke Sun
% Date: 25/7/2024
% Vesion: 

% Note: Raw data file called Data.mat storing syncrhonized acceleration and gyroscope data 
% need to be downloaded from OSF, link: https://osf.io/498up/
% and save in the Data folder in this folder in order for prepareData function to work
%% Setup

close all;
clc;

% Add functions to path
addpath('scr')
addpath('scr/wavelet-coherence-master')
%%
% Configuration
CONFIG = struct();
CONFIG.SENSOR_TYPE = "ACC";  % "ACC" for Accelerometer, "GYR" for Gyroscope
CONFIG.SIDE = 'R';           % 'R' for Right side, 'L' for Left side
CONFIG.FILTER_CUTOFF = 10;   % Filter cutoff frequency in Hz
CONFIG.TIME_STEP = 0.04;     % Time step in seconds

%% Data Preparation 
% Load session information
load(fullfile('Info', 'allinfostr'), 'SessionNames');

[OriData, ParLabels] = prepareData(SessionNames, CONFIG);

%% Cross Wavelet Analysis for all sessions in SocSensor Dataset
% Use Process-Based parallel pool,  dtw function in Matalb doesnot support thread-based parallel pool
parpool('Processes');

WA_CONFIG = struct();
WA_CONFIG.NORM_FLAG = false;
% WA_CONFIG.SCALE_RANGE = [[0.5, 15];[0.5,5],[5,15]];
WA_CONFIG.SCALE_RANGE = [[0.5, 15];[0.5,5];[5,15];[0.5:0.5:4.5;1:0.5:5]';[5:1:14;6:1:15]'];
WA_data = performWaveletAnalysis(OriData, CONFIG.TIME_STEP, WA_CONFIG);

%% Cross-Correlation Analysis for all sessions SocSensor Dataset
CC_CONFIG = struct();
CC_CONFIG.WINDOW_SIZE = 5.04;
CC_CONFIG.STEP_SIZE = 5.04/2;
% Max lag
CC_CONFIG.WCOEF = [0.5, 0.45, 0.4, 0.35, 0.3, 0.25, 0.2, 0.17, 0.15, 0.12, 0.1, 0.05, 0];
CC_CONFIG.REMOVE_GRAVITY = false;
CC_CONFIG.NORM_FLAG = true;
CC_CONFIG.WINDOW_NORM_FLAG = false;
CC_CONFIG.SCALE_OPT = "none";

CC_data = performCrossCorrelation(OriData, CONFIG.TIME_STEP, CC_CONFIG);

%% Dynamic Time Warping Analysis for all sessions
DTW_CONFIG = struct();
DTW_CONFIG.WINDOW_SIZE = 5.04;
DTW_CONFIG.STEP_SIZE = 5.04/2;
% Warping Path
DTW_CONFIG.WCOEF = [0.5, 0.45, 0.4, 0.35, 0.3, 0.25, 0.2, 0.17, 0.15, 0.12, 0.1, 0.05, 0];
DTW_CONFIG.REMOVE_GRAVITY = false;
DTW_CONFIG.NORM_FLAG = false;
DTW_CONFIG.WINDOW_NORM_FLAG = true;

DTW_data = performDTW(OriData, CONFIG.TIME_STEP, DTW_CONFIG);
%%  Euclidean distance Analysis for all sessions
ED_CONFIG = struct();
ED_CONFIG.WINDOW_SIZE = 5.04;
ED_CONFIG.STEP_SIZE = 5.04/2;
% Warping Path =0 for Euclidean distance Analysis
ED_CONFIG.WCOEF = 0;
ED_CONFIG.REMOVE_GRAVITY = false;
ED_CONFIG.NORM_FLAG = false;
ED_CONFIG.WINDOW_NORM_FLAG = false              ;

ED_data = performDTW(OriData, CONFIG.TIME_STEP, ED_CONFIG);
%% Save processed data (Optional)
%save(fullfile('Analysis','ProcessedData.mat'), 'OriData', 'ParLabels', 'WA_data', 'CC_data', 'DTW_data','ED_data');

