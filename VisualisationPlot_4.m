%% Add functions to path
addpath('scr')
addpath('scr/wavelet-coherence-master')
%% Load acceleration signal
% load data previously saved
% alternaltively generate in SimialrityAnalysis.mat

load(fullfile('Analysis','Data.mat'),'OriData','ParLabels')
%% Training data use specific fold 
% We are using session 7 as an example,
session= "SJV day 1";
% load feature saved previously
% alternaltively generated from Classfication3
load(fullfile('Analysis','features.mat'),'f')
fMat=f;
% ensemble bagged tree
template = templateTree(...
    'MaxNumSplits',200,...
    'Surrogate','on',...
    'NumVariablesToSample', 'all');

rng(11); % Set the seed for the random number generator
% session 7 is test data 
% the rest of sessions are used for training 
groups={7};
%-------------------------------------------------------------------------
[EvaluationMetric,EMtable,Model]=modelBaggingTrain(fMat,InteractionLevel,groups,SessionPairLabel...
    ,'template',template,'NumLearningCycles',NumLearningCycles);

%% Data preparation for plotting tiger plots and network plot
% load analysis previously saved 
% alternaltively use simiarlity measures generated in SimialrityAnalysis.mat

% load('Analysis\WAfullrange.mat','WAOri')
fsession=regexprep(session, ' ', '_');

% load('Analysis\Data1.mat','CCOriMax')
spcecificCC=CCOriMax.(fsession).('NWOri_func0_W126S63');
% datause=CCOriMax.(fsession).('Ori_NOg_func0_W126S63');
for i=1:length(spcecificCC)
spcecificCC{i,1}=spcecificCC{i,1}(7,:);
end

% load('Analysis\Data1.mat','DTWOri')
spcecificDTW=DTWOri.(fsession).("NOri_W126S63");
spcecificED=DTWOri.(fsession).("Ori_NOg_W126S63");
for i=1:length(spcecificDTW)
spcecificDTW{i,1}=spcecificDTW{i,1}(7,:);
spcecificED{i,1}=spcecificED{i,1}(13,:);
end


%% Combine the selected features for plot generation
CombinedAlg=dataInput4Plot(WAOri.(fsession).('xwScave27_86')...
    ,WAOri.(fsession).('wcohScave27_86'),spcecificCC,spcecificDTW,spcecificED);
 
%% Plot Tiger plot
% Select the person to plot
ChildName='M12';

selevent2=[1008,	1039,	1378,	1702,	1852,	2204,	2286,	2724,	3055,	3164,	3213,	3282,	3314, 3714];

% plotRange=[2724,3049];
% With event codes and Addingup Flag
[TIV]=TigerPlot_ML(session,ChildName,CombinedAlg,OriData.(fsession),ParLabels.(fsession),Model{1},...
'PlotRangeSocSensorFlag',true,'AddingUpFlag',true,'EventsTime',selevent2,'FontSize',26);

%% Generate network plots
NetworkPlot_ML(session,CombinedAlg,OriData.(fsession),ParLabels.(fsession),Model{1},...
             'PlotRangeSocSensorFlag',true,'PlotType','NT');

%% Overall interaction

ParLabel=ParLabels.(fsession);
for i=1:length(ParLabel)
    ChildName=ParLabel(i);
    [TIV]=TigerPlot_ML(session,ChildName,CombinedAlg,OriData.(fsession),ParLabel,Model{1},...
        'PlotRangeSocSensorFlag',true,'figureFlag',false);
    if i==1
        TIVsum=any(TIV,1);
    else
        TIVsum=[TIVsum;any(TIV,1)];
    end
end
%
figure
h=heatmap(cellstr("Day 3"),cellstr(ParLabel),sum(TIVsum,2)/length(TIVsum));
h.ColorLimits=[0.1,0.2];
set(findall(gcf,'-property','FontSize'),'FontSize',18)
%
genTigerPlot(TIVsum,ParLabels.(fsession),'AddingUpFlag',true,'EventsCodeEdge',0.5,'FontSize',36)