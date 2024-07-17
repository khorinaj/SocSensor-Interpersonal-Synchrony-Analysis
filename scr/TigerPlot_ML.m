function bintAll = TigerPlot_ML(session, ChildName, CombinedAlg, SyncData, ParLabel, Model, varargin)
% TIGERPLOT_ML Generates visualizations for interactions of the selected person 
% with all the other people in this session across timeline.
% The pretrained Model is used on CombinedAlg for predicting interaction
% level, Tigerplots is generated indicating high or low interaction
%
% INPUTS:
%   - session (string): Name of the session.
%   - ChildName (string): Name of the child.
%   - CombinedAlg (struct): Struct containing algorithm data (use as features in Model).
%   - SyncData (matrix): Synchronized data matrix for this session.
%   - ParLabel (cell array): Labels of participants for this session.
%   - Model (object): Pre-trained model for prediction.
%   - varargin (optional parameters):
%       - 'PlotRangeSocSensorFlag' (logical): Flag to use the default plot range based on SocSensor data.
%       - 'PlotRange' (vector): Range for plotting.
%       - 'AddingUpFlag' (logical): Flag to add up the interactions for multiple pairs.
%       - 'EventsTime' (double array): Timing information for events.
%       - 'FontSize' (int): Font size for the plot.
%       - 'figureFlag' (logical): Flag to display the figure.
% OUTPUTS:
%   - bintAll (matrix): Binary interaction values for the child with all other participants.
%
% The function generates visualizations to show the interactions of a specified child with other participants in a session. It uses real algorithm data, synchronized data, participant labels, and a pre-trained model for prediction.

% Extract time and data information
NormTime = SyncData(:, 1);
DataSize = size(SyncData(:, 2:end), 2);
MyOrder = nchoosek(1:DataSize, 2);
fname = regexprep(session, ' ', '_');

% Default values for optional parameters
figureFlag = true;
PlotRangeSocSensorFlag = false;
PlotRangeFlag = false;
AddingUpFlag = false;
EventsCodeFlag = false;
EventsCodeEdge = 2.5;
fontsize = 20;

% Parse optional parameters
for i = 1:numel(varargin)
    if ischar(varargin{i}) && strcmpi(varargin{i}, 'figureFlag')
        if i < numel(varargin)
            figureFlag = varargin{i + 1};
        end
    elseif ischar(varargin{i}) && strcmpi(varargin{i}, 'PlotRangeSocSensorFlag')
        if i < numel(varargin)
            PlotRangeSocSensorFlag = varargin{i + 1};
        end
    elseif ischar(varargin{i}) && strcmpi(varargin{i}, 'PlotRange')
        if i < numel(varargin)
            PlotRange = varargin{i + 1};
            PlotRangeFlag = true;
        end
    elseif ischar(varargin{i}) && strcmpi(varargin{i}, 'AddingUpFlag')
        if i < numel(varargin)
            AddingUpFlag = varargin{i + 1};
        end
    elseif ischar(varargin{i}) && strcmpi(varargin{i}, 'EventsTime')
        if i < numel(varargin)
            EventsTime = varargin{i + 1};
            EventsCodeFlag = true;
        end
    elseif ischar(varargin{i}) && strcmpi(varargin{i}, 'EventsCodeEdge')
        if i < numel(varargin)
            EventsCodeEdge = varargin{i + 1};
        end
    elseif ischar(varargin{i}) && strcmpi(varargin{i}, 'FontSize')
        if i < numel(varargin)
            fontsize = varargin{i + 1};
        end
    end
end

% Check for conflicting PlotRange flags
if and(PlotRangeFlag, PlotRangeSocSensorFlag)
    PlotRangeSocSensorFlag = false;
    warning("Plot range will be based on the input ranges")
end

% Set PlotRange based on SocSensor data if flag is true
if PlotRangeSocSensorFlag
    infofile = fullfile('Info', strcat('Info', '_', fname));
    load(infofile, 'norm_TT', 'event', 'scale_factor')
    SessionRange = [norm_TT(event == "session start"), norm_TT(event == "session end")];
    [~, ll] = min(abs(NormTime - SessionRange(1)));
    [~, lh] = min(abs(NormTime - SessionRange(2)));
    PlotRange = ll:lh;
    if EventsCodeFlag
        EventsTime = EventsTime / scale_factor - SessionRange(1);
    end
elseif PlotRangeFlag
    infofile = fullfile('Info', strcat('Info', '_', fname));
    load(infofile, 'scale_factor')
    [~, ll] = min(abs(NormTime - PlotRange(1) / scale_factor));
    [~, lh] = min(abs(NormTime - PlotRange(2) / scale_factor));
    PlotRange = ll:lh;
    if EventsCodeFlag
        EventsTime = EventsTime / scale_factor - PlotRange(1) / scale_factor;
    end
end

% Find the index of the child in ParLabel
ChildLoc = find(ParLabel == ChildName);
com = find(or(MyOrder(:, 1) == ChildLoc, MyOrder(:, 2) == ChildLoc));

% Initialize binary interaction matrix
bintAll = [];

for i = 1:length(com)
    % Combine algorithm data for the selected pairs
    FN = fieldnames(CombinedAlg);
    DataReal = [];
    for j = 1:length(FN)
        DataReal = [DataReal; CombinedAlg.(FN{j}){com(i), 1}];
    end

    % Apply PlotRange if flags are set
    if or(PlotRangeSocSensorFlag, PlotRangeFlag)
        DataReal = DataReal(:, PlotRange);
    end

    % Calculate window size and indices for averaging
    windowsize = round(5 / 0.04); % Assuming 0.04 is the sampling rate
    idx = 1:windowsize:length(DataReal);
    if idx(end) ~= length(DataReal)
        idx = [idx, length(DataReal) + 1];
    end

    % Calculate average data and predict interactions
    DataAves = [];
    for j = 1:(length(idx) - 1)
        idxend = idx(j) + windowsize - 1;
        if idxend > length(DataReal)
            idx(j) = length(DataReal) - windowsize + 1;
            idxend = length(DataReal);
        end
        DataAve = mean(DataReal(:, idx(j):idxend)', 1);
        DataAves = [DataAves; DataAve];
    end

    [prediction, ~] = predict(Model, DataAves);
    bint = zeros(1, length(DataReal));
    for j = 1:(length(idx) - 1)
        idxend = idx(j) + windowsize - 1;
        if idxend > length(DataReal)
            idx(j) = length(DataReal) - windowsize + 1;
            idxend = length(DataReal);
        end
        bint(idx(j):idxend) = repmat(prediction(j), 1, length(idx(j):idxend));
    end

    % Aggregate binary interaction values
    if i == 1
        bintAll = bint;
    else
        bintAll = [bintAll; bint];
    end
end

% Generate titles for the plots
titleName = strings(size(bintAll, 1), 1);
for i = 1:size(bintAll, 1)
    if MyOrder(com(i), 1) == ChildLoc
        titleName(i) = strcat(ParLabel(MyOrder(com(i), 1)), '&', ParLabel(MyOrder(com(i), 2)));
    else
        titleName(i) = strcat(ParLabel(MyOrder(com(i), 2)), '&', ParLabel(MyOrder(com(i), 1)));
    end
end

% Generate and display the plots if the flag is set
if figureFlag
    if EventsCodeFlag
        genTigerPlot(bintAll, titleName, 'AddingUpFlag', AddingUpFlag, 'EventsTime', EventsTime, 'EventsCodeEdge', EventsCodeEdge, 'FontSize', fontsize);
    else
        genTigerPlot(bintAll, titleName, 'AddingUpFlag', AddingUpFlag, 'EventsCodeEdge', EventsCodeEdge, 'FontSize', fontsize);
    end
end
end
