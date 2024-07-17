%% Add functions to path
addpath('scr')
addpath('scr/wavelet-coherence-master')
%% load analysis that previously saved
% load analysis previously saved 
% alternaltively use simiarlity measures generated in SimialrityAnalysis.mat
load(fullfile('Analysis','Data.mat'),'OriData','ParLabels','WAOri')

%% Extract Algorithm values from selected time points(times when video is scored) for all sessions

[VideoScore,AlgValueAverage,AlgrithmList,SessionPairLabel]=...
          ExtractAlgValuesFromTimePoints(OriData,ParLabels,WAOri);

% VideoScore have four colomns representing four different scores as ground
% truth: 
%% Check Rsquare of each algorithm
% Can select different groups
% groupSel=or(SessionPariLabel(:,1)=="SJV day 1", SessionPariLabel(:,1)=="SJV day 4");
% groupSel=or(or(SessionPariLabel(:,1)=="QM day 1 EY", SessionPariLabel(:,1)=="QM day 2 EY"),SessionPariLabel(:,1)=="QM day 3 EY");
% groupSel=or(or(SessionPariLabel(:,1)=="Q4 day 1", SessionPariLabel(:,1)=="Q4 day 2"),SessionPariLabel(:,1)=="Q4 day 3");
rsquare=genRsquare(AlgValueAverage, AlgrithmList, VideoScore(:, 2));
%%  Different Combination of features. 
AlgName1=["XWT","WCT","CC","DTW","ED"];
%% Prepare Alogrithm used to combine
% load analysis previously saved 
% alternaltively use simiarlity measures generated in SimialrityAnalysis.mat

% WA anlaysis saved previously
load('Analysis\WAfullrange.mat','WAOri')
[VideoScore,AlgValueAverage,AlgrithmList,~]=ExtractAlgValuesFromTimePoints(OriData,ParLabels,WAOri);
f=AlgValueAverage;
AlgName=AlgrithmList;

% CC anlaysis saved previously
load('Analysis\Data1.mat','CCOriMax')
[~,AlgValueAverage,AlgrithmList,~]=ExtractAlgValuesFromTimePoints(OriData,ParLabels,CCOriMax);
f=[f,AlgValueAverage(:,33)];
AlgName=[AlgName,AlgrithmList(33)];

% DTW anlaysis saved previously
load('Analysis\Data1.mat','DTWOri')
[~,AlgValueAverage,AlgrithmList,~]=ExtractAlgValuesFromTimePoints(OriData,ParLabels,DTWOri);
f=[f,AlgValueAverage(:,[46,26])];
AlgName=[AlgName,AlgrithmList([46,26])];

%% Session dependent cross validation
groups = splitSessionDependFold(5, SessionPairLabel);
%% Generate R square for combinition of features 
NofeatureCombine=2;
[StaResults, fullAlgList] = genR4CombinedFeatures(f, AlgName1, VideoScore(:, 2), groups, NofeatureCombine, SessionPairLabel);
