%% Add functions to path
addpath('scr')
addpath('scr/wavelet-coherence-master')
%% Load acceleration signal
% load data previously saved
% alternaltively generate in SimialrityAnalysis.mat
load(fullfile('Analysis','Data.mat'),'OriData','ParLabels')
%% Prepare SIMILARITY FEATURE used for CLASSIFICATION
% load analysis previously saved 
% alternaltively use simiarlity measures generated in SimialrityAnalysis.mat

% WA anlaysis saved previously
load(fullfile('Analysis','WAfullrange.mat'),'WAOri')
[VideoScore,AlgValueAverage,AlgrithmList,SessionPairLabel,TimeValues]=ExtractAlgValuesFromTimePoints(OriData,ParLabels,WAOri);
f=AlgValueAverage;
AlgName=AlgrithmList;

% CC anlaysis saved previously
load(fullfile('Analysis','Data1.mat'),'CCOriMax')
[~,AlgValueAverage,AlgrithmList,~]=ExtractAlgValuesFromTimePoints(OriData,ParLabels,CCOriMax);
f=[f,AlgValueAverage(:,33)];
AlgName=[AlgName,AlgrithmList(33)];

% DTW anlaysis saved previously
load(fullfile('Analysis','Data1.mat'),'DTWOri')
[~,AlgValueAverage,AlgrithmList,~]=ExtractAlgValuesFromTimePoints(OriData,ParLabels,DTWOri);
f=[f,AlgValueAverage(:,[46,26])];
AlgName=[AlgName,AlgrithmList([46,26])];

%% Extract Baseline features

Baselinef = extractStatsticsFeature(OriData, ParLabels, TimeValues, SessionPairLabel);

%% Alternalyivly use features saved 
load(fullfile('Analysis','features.mat'),'f','Baselinef')
%% Define Classification labels
InteractionLevel=zeros(size(VideoScore(:,2)));
InteractionLevel(VideoScore(:,2)>2)=1;

%% Session depedent cross validation
groups = splitSessionDependFold(5, SessionPairLabel);
%% Training data for each fold
fMat=f;
% fMat=Baselinef;
rng(11); % Set the seed for the random number generator
%-------------------------------------------------------------------------
% ensemble bagged tree
template = templateTree(...
    'MaxNumSplits',2000,...
    'Surrogate','on',...
    'NumVariablesToSample', 'all');
NumLearningCycles=60;
% % Random forest
% numVarToSample = sqrt(size(trainData, 2));
% template = templateTree(...
%     'MaxNumSplits', 2000, ...
%     'Surrogate', 'on', ...
%     'NumVariablesToSample', numVarToSample);

[EvaluationMetric,EMtable]=modelBaggingTrain(fMat,InteractionLevel,groups,SessionPairLabel...
    ,'template',template,'NumLearningCycles',NumLearningCycles);
%% Saved model can be used 
fMat=f;

% Load session names from the information file
load(fullfile('Analysis', 'Classification.mat'), 'SimilarityModel','BaselineModel');
[EvaluationMetric,EMtable]=modelBaggingTrain(fMat,InteractionLevel,groups,SessionPairLabel,...
    'SavedModel',SimilarityModel);