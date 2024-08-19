%% Feature Analysis through linear regression
% This script analysis Rsquare and pvalues from linear regression for different
% similarity measures and different combinition of similarity measures
% Author:
% Date: 25/7/2024

%% Add functions to path
addpath('scr')
addpath('scr/wavelet-coherence-master')
close all;
clc;
%% load analysis that previously saved
% Use simiarlity measures generated in SimialrityAnalysis_1.mat
% Alternatively load analysis previously saved 
%load(fullfile('Analysis','ProcessedData.mat'), 'OriData', 'ParLabels', 'WA_data', 'CC_data', 'DTW_data',','ED_data'');


%% Extract Algorithm values from time points(when video is scored) for all sessions
% VideoScore have four colomns representing four different scores as ground
% truth: attention, motor, proximity and overall

[VideoScore,AlgValueAverage,AlgrithmList,SessionPairLabel]=...
          ExtractAlgValuesFromTimePoints(OriData,ParLabels,ED_data);

%% Check Rsquare of individual algorithm

% Uncomment and modify the following lines to select different groups
% groupSel=or(SessionPariLabel(:,1)=="SJV day 1", SessionPariLabel(:,1)=="SJV day 4");
% groupSel=or(or(SessionPariLabel(:,1)=="QM day 1 EY", SessionPariLabel(:,1)=="QM day 2 EY"),SessionPariLabel(:,1)=="QM day 3 EY");
% groupSel=or(or(SessionPariLabel(:,1)=="Q4 day 1", SessionPariLabel(:,1)=="Q4 day 2"),SessionPariLabel(:,1)=="Q4 day 3");

rsquare=genRsquare(AlgValueAverage, AlgrithmList, VideoScore(:, 2));

%% Checking Rsqure of combinition of features:
%% Prepare Alogrithm lists used to combine 
% Use simiarlity measures generated in SimialrityAnalysis_1.mat
% Alternatively load analysis previously saved 
%load(fullfile('Analysis','ProcessedData.mat'), 'OriData', 'ParLabels', 'WA_data', 'CC_data', 'DTW_data');

% Extract WA anlaysis at time points with a groud truth value(scored video clips by researchers)
[VideoScore,WA_Scored,WA_Alglist,~]=ExtractAlgValuesFromTimePoints(OriData,ParLabels,WA_data);
% Extract CC anlaysis at time points with a groud truth value
[~,CC_Scored,CC_Alglist,~]=ExtractAlgValuesFromTimePoints(OriData,ParLabels,CC_data);
% Extract DTW anlaysis at time points with a groud truth value
[~,DTW_Scored,DTW_Alglist,~]=ExtractAlgValuesFromTimePoints(OriData,ParLabels,DTW_data);
% Extract DTW anlaysis at time points with a groud truth value
[~,ED_Scored,ED_Alglist,~]=ExtractAlgValuesFromTimePoints(OriData,ParLabels,ED_data);

% 
WAsel=[3,4,5,6]; % change value upon preference
% Select MAX LAG used in CC
CCsel=7; % change value upon preference
% Select WRAPING PATH used in DTW
DTWsel=7; % change value upon preference
f=[WA_Scored(:,WAsel),CC_Scored(:,CCsel),DTW_Scored(:,DTWsel),ED_Scored];


% Name selected features. 
% AlgName1=["XWT","WCT","CC","DTW","ED"];
AlgName1=["XWTH","WCTH","XWTL","WCTL","CC","DTW","ED"];
%% Session dependent cross validation
groups = splitSessionDependFold(5, SessionPairLabel);
%% Generate R square for combinition of features 

% Select No. of feature combined
NofeatureCombine=4;
[StaResults, fullAlgList] = genR4CombinedFeatures(f, AlgName1, VideoScore(:, 2), groups, NofeatureCombine, SessionPairLabel);
