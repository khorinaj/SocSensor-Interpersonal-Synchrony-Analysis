%% Visualization of Classification Results and Interaction Patterns
% This script use classification for generating thresholds for visualisation plot
% and generates various figures to dsiplay the interaction dynamics in
% groups
% This tiger plots and network plots for specific sessions and participants.
% 
% Author: Yanke Sun
% Date: 25/7/2024

%% Setup
close all;
clc;

% Add functions to path
addpath('scr')
addpath('scr/wavelet-coherence-master')
%% Load Data
% Use varaiables generated in SimialrityAnalysis_1.mat,Classification_3.m
% Alternatively load analysis previously saved 
%load(fullfile('Analysis','ProcessedData.mat'), 'OriData', 'ParLabels', 'WA_data', 'CC_data', 'DTW_data');
load(fullfile('Analysis','features.mat'),'f');
save(fullfile('Analysis','classification.mat'),'SessionPairLabel','VideoScore')
%% Select Session for Analysis
session = "SJV day 1";
fsession = regexprep(session, ' ', '_');

%% Train Classification Model for generating threshold value 
fMat = f;
% fMat = Baselinef;
template = templateTree('MaxNumSplits', 2000, 'Surrogate', 'on', 'NumVariablesToSample', 'all');
NumLearningCycles = 60;
groups = {7}; % Session 7 as test data, rest for training
randomState=11; % Set random state for reproducibility
% Create binary labels based on VideoScore
InteractionLevel = zeros(size(VideoScore(:,2)));% Use motor score here
InteractionLevel(VideoScore(:,2) > 2) = 1; % Set threshold at 2

%%
% Train model
[EvaluationMetric, EMtable, Model] = modelBaggingTrain(fMat, InteractionLevel, groups, SessionPairLabel, ...
    'template', template, 'NumLearningCycles', NumLearningCycles,'randomState',randomState);

%% Prepare Data for Visualization

% Extract specific measures for the selected session
% The order should be the same as the simialrity features used for training
specificXWT=WA_data.(fsession).('xwScave27_86');
specificWCT=WA_data.(fsession).('wcohScave27_86');
spcecificCC = CC_data.(fsession).('Ncc_W126S63');
% Select MAX LAG used in CC
CCsel=7; % change value upon preference
spcecificDTW = DTW_data.(fsession).("WNdtw_W126S63");
% Select WRAPING PATH used in DTW
DTWsel=7; % change value upon preference
spcecificED = ED_data.(fsession).("dtw_W126S63");% ED

% Process specific measures
for i = 1:length(spcecificCC)
    spcecificCC{i,1} = spcecificCC{i,1}(CCsel,:); % change for select different paramenters
    spcecificDTW{i,1} = spcecificDTW{i,1}(DTWsel,:);% change for select different paramenters
    spcecificED{i,1} = spcecificED{i,1};
end

%% Combine Selected Features for Plotting
CombinedAlg = dataInput4Plot(specificXWT,specificWCT,spcecificCC, spcecificDTW, spcecificED);
%% Generate Tiger Plot for Specific Participant
ChildName = 'M12';
selevent2 = [1008, 1039, 1378, 1702, 1852, 2204, 2286, 2724, 3055, 3164, 3213, 3282, 3314, 3714];

[TIV] = TigerPlot_ML(session, ChildName, CombinedAlg, OriData.(fsession), ParLabels.(fsession), Model{1}, ...
    'PlotRangeSocSensorFlag', true, 'AddingUpFlag', true, 'EventsTime', selevent2, 'FontSize', 26);

%% Generate Network Plot
NetworkPlot_ML(session, CombinedAlg, OriData.(fsession), ParLabels.(fsession), Model{1}, ...
    'PlotRangeSocSensorFlag', true, 'PlotType', 'NT');

%% Generate Overall Interaction Heatmap
ParLabel = ParLabels.(fsession);

for i = 1:length(ParLabel)
    ChildName = ParLabel(i);
    [TIV] = TigerPlot_ML(session, ChildName, CombinedAlg, OriData.(fsession), ParLabel, Model{1}, ...
        'PlotRangeSocSensorFlag', true, 'figureFlag', false);
    if i==1
        TIVsum= any(TIV, 1);
    else
        TIVsum=[TIVsum;any(TIV, 1)];
    end
end

% Plot heatmap
figure;
h = heatmap(cellstr("Day 3"), cellstr(ParLabel), sum(TIVsum, 2) / size(TIVsum, 2));
h.ColorLimits = [0.1, 0.2];
set(findall(gcf, '-property', 'FontSize'), 'FontSize', 18);

% Generate overall tiger plot
genTigerPlot(TIVsum, ParLabels.(fsession), 'AddingUpFlag', true, 'EventsCodeEdge', 0.5, 'FontSize', 36);
