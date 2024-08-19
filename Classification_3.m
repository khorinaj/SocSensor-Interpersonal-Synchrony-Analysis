%% Classification interation level 
% This script performs classification of interation level(Store in VideoScore) using
% similarity features or baseline features. It includes options for feature extraction,
% model training, and evaluation. The main steps are:
% 1. Data loading
% 2. Feature extraction (two options provided)
% 3. Classification setup
% 4. Model training (Ensemble Bagged Tree or Random Forest)
% 5. Model evaluation
% 
% Author: Yanke SUN
% Date: 25/7/2024

%% Add functions to path
addpath('scr')
addpath('scr/wavelet-coherence-master')
close all;
clc;
%% Load acceleration signal and analysis that previously saved
% Use simiarlity measures generated in SimialrityAnalysis_1.mat
% Alternatively load analysis previously saved 
%load(fullfile('Analysis','ProcessedData.mat'), 'OriData', 'ParLabels', 'WA_data', 'CC_data', 'DTW_data');

%% Feature Extraction from time points with ground truth data
% Choose between Option 1 (prepare own features) or Option 2 (load pre-saved features
%% Option 1: Prepare SIMILARITY FEATURES for CLASSIFICATION
% This section extracts features using various analysis methods (WA, CC, DTW)

% Extract WA anlaysis at time points with a groud truth value(scored video clips by researchers)
[VideoScore,WA_Scored,WA_Alglist,SessionPairLabel,TimeValues]=ExtractAlgValuesFromTimePoints(OriData,ParLabels,WA_data);
% Extract CC anlaysis at time points with a groud truth value
[~,CC_Scored,CC_Alglist,~]=ExtractAlgValuesFromTimePoints(OriData,ParLabels,CC_data);
% Extract DTW anlaysis at time points with a groud truth value
[~,DTW_Scored,DTW_Alglist,~]=ExtractAlgValuesFromTimePoints(OriData,ParLabels,DTW_data);
% Extract DTW anlaysis at time points with a groud truth value
[~,ED_Scored,ED_Alglist,~]=ExtractAlgValuesFromTimePoints(OriData,ParLabels,ED_data);

% 
WAsel=[1,2]; % change value upon preference
% Select MAX LAG used in CC
CCsel=7; % change value upon preference
% Select WRAPING PATH used in DTW
DTWsel=7; % change value upon preference
f=[WA_Scored(:,WAsel),CC_Scored(:,CCsel),DTW_Scored(:,DTWsel),ED_Scored];

%% Option 1 (continued): Extract BASELINE features 
% (Statistical features of raw data at time points with a groud truth value)

% Extract statistical features from original data
Baselinef = extractStatsticsFeature(OriData, ParLabels, TimeValues, SessionPairLabel);

%% Option 2: Load Pre-extracted Features
% Use features previously extracted and saved by the author
% Uncomment the following line to use Option 2
% load(fullfile('Analysis','features.mat'),'f','Baselinef')

%% Define Classification labels

% Create binary labels based on VideoScore
InteractionLevel = zeros(size(VideoScore(:,2)));% Use motor score here
InteractionLevel(VideoScore(:,2) > 2) = 1; % Set threshold at 2

%% Session dependent cross-validation
% Split data into folds for cross-validation
groups = splitSessionDependFold(5, SessionPairLabel);

%% Prepare training data for each fold
% Choose between similarity features (f) or baseline features (Baselinef)
fMat = f;
% Uncomment the following line to use baseline features instead
% fMat = Baselinef;

%% Model Configuration
% Choose between Ensemble Bagged Tree and Random Forest models
% Uncomment the desired model configuration


% Ensemble Bagged Tree configuration
% Tuning parameters upon preference
template = templateTree(...
    'MaxNumSplits', 2000, ...
    'Surrogate', 'on', ...
    'NumVariablesToSample', 'all');
numTrees = 100;
randomState=12;
% % Random Forest configuration
% % Uncomment and adjust as needed
% Tuning parameters upon preference
% numVarToSample = sqrt(size(fMat, 2));
% template = templateTree(...
%     'MaxNumSplits', 2000, ...
%     'Surrogate', 'on', ...
%     'NumVariablesToSample', numVarToSample);
% NumLearningCycles = 60;

%% Model Training and Evaluation
% Train the model and compute evaluation metrics
[EvaluationMetric, EMtable] = modelBaggingTrain(fMat, InteractionLevel, groups, SessionPairLabel, ...
    'template', template, 'NumLearningCycles', numTrees,'randomState',randomState);

%% Using Saved Models(used in paper) (Optional)
% This section demonstrates how to use previously saved models

fMat = f;  % Ensure using the correct feature set for different saved models
% Load saved models
load(fullfile('Analysis', 'Classification.mat'), 'SimilarityModel', 'BaselineModel');
ModelUse=SimilarityModel;

% Evaluate using the saved model
[EvaluationMetric, EMtable] = modelBaggingTrain(fMat, InteractionLevel, groups, SessionPairLabel, ...
    'SavedModel', ModelUse);

%% Results Visualization (Optional)
% Add code here to visualize results, e.g., confusion matrix, ROC curve, etc.

%% Save Results (Optional)
% Add code here to save the trained model, evaluation metrics, etc.