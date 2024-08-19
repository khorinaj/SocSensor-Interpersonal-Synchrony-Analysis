function [filtOriData, ParticipantLabels] = DataPrepare(session, sensortype, RLtype, FiltCutoff)
% DATAPREPARE Prepares and filters data for a given session, sensor type, and hand type.
%
% Syntax:
% [filtOriData, ParticipantLabels] = DataPrepare(session, sensortype, RLtype, FiltCutoff)
%
% Inputs:
% session - Session name (string), listed in ('Info\allinfostr', 'SessionNames')
% sensortype - Sensor type (string), 'ACC' for accelerometer, 'GYR' for gyroscope
% RLtype - Hand type (char), 'R' for right hand, 'L' for left hand
% FiltCutoff - Cutoff frequency for 4th order Butterworth filter (Hz)
%
% Outputs:
% filtOriData - Filtered original data
% ParticipantLabels - Participant labels for the filtered data
%
% Example:
% [filtOriData, ParticipantLabels] = DataPrepare('Session1', 'ACC', 'R', 20)
%
% Note: Part of the Socsensor Dataset processing pipeline

% Load session info
load(fullfile('Info','allinfostr'),'allinfostr')
if ~ismember(session, allinfostr(:, 4))
    error('Session does not exist in Socsensor Dataset');
end

if ~ismember(sensortype,["ACC","GYR"])
    error('Wrong sensortype input: should be either ACC or GYR ');
end

if ~ismember(RLtype,["L","R"])
    error('Wrong RLtype input: should be either L or R');
end

% Load data
load('Data\Data.mat', 'originalData', 'dataLabel');
fname = regexprep(session, ' ', '_');
Sync_data = originalData.(sensortype).(fname).('Mag');
DataLabel = dataLabel.(sensortype).(fname);

% Load session-specific information
infofile = fullfile('Info', strcat('Info_', regexprep(session, ' ', '_'), '.mat'));
disp(infofile)
% save(fullfile('Data',strcat(regexprep(session, ' ', '_'),'_',sensortype, '_Mag.mat')),'Sync_data','DataLabel','-v7.3')
% filtOriData=0;
% ParticipantLabels=0;


load(infofile, 'norm_t');

% Extract data and time
data = Sync_data(:, 2:end);
t = norm_t;
resample_fs = 1 / ((Sync_data(2, 1) - Sync_data(1, 1)) / 1000);

% Select hand type data
if RLtype == 'R'
    load(infofile, 'Rsensor_Label');
    sensor_Label = Rsensor_Label;
elseif RLtype == 'L'
    load(infofile, 'Lsensor_Label');
    sensor_Label = Lsensor_Label;
else
    error('RLtype must be either L or R');
end

% Map sensor labels to data labels
Label = nan(1, length(sensor_Label));
for i = 1:length(sensor_Label)
    if ~isnan(sensor_Label(i))
        Label(i) = find(sensor_Label(i) == DataLabel);
    end
end
RL = Label(~isnan(Label));

% Get participant labels
load(infofile, 'Par_Label');
ParticipantLabels = Par_Label(~isnan(Label));

% Select relevant data
datasel = data(:, RL);

% Apply low-pass filter
[LPa, LPb] = butter(4, FiltCutoff / (resample_fs / 2), 'low');
filtOriData = [t, filtfilt(LPa, LPb, datasel)];

end