function varargout = NetworkPlot_ML(session,AlgDataReal,SyncData,ParLabel,Model,varargin)
% NETWORKPLOT plots network generate plots of connectivity patterns bewteen
% pairs of people
%
% INPUTS:
%   - session (string): Name of the session.
%   - AlgDataReal (struct): Struct containing real algorithm data.
%   - AlgDataPsu (struct): Struct containing pseudorandom algorithm data.
%   - SyncData (matrix): Synchronized data matrix.
%   - ParLabel (strings): Participants' labels.
%   - varargin (optional parameters):
%       - 'PlotRangeSocSensorFlag' (logical): Flag to use default plot range based on SocSensor data
%       - 'Threshold' (double): Threshold value to take from psuedo data used in MATLAB buitin function pctile(from [0-100]).
%
% OUTPUTS:
%   - varargout{1}: PerTimeOverThres (double array): PerTimeOverThres values for each pair.
%   - varargout{2}: Pairs (strings): Pairs labels corresponding to each PerTimeOverThres.
%
% EXAMPLE:
%     NetworkPlot(session,AlgDataReal,AlgDataPsu,SyncData,ParLabel,'PlotRangeSocSensorFlag',false,'AlgWeight', weight,'Threshold',95)

NormTime=SyncData(:,1);
DataSize=size(SyncData(:,2:end),2);
MyOrder = nchoosek(1:DataSize,2);
fname=regexprep(session, ' ', '_');

% Find if SocSensor Flag is true, if it is true then the a defalt
% plot range is set from session start to end
PlotRangeSocSensorFlag=false;
for i = 1:numel(varargin)
    if ischar(varargin{i}) && strcmpi(varargin{i}, 'PlotRangeSocSensorFlag')
        % Look for 'method' in varargin and set the method variable

        if i < numel(varargin)
            PlotRangeSocSensorFlag = varargin{i + 1};
            break
        end

    end

    % Add more conditions to handle other optional parameters if needed
end

% Select Plot Type
PlotType="IM";
for i = 1:numel(varargin)
    if ischar(varargin{i}) && strcmpi(varargin{i}, 'PlotType')
        if i < numel(varargin)
            PlotType = varargin{i + 1};
            break
        end
    end
end

PlotRangeFlag=false;
for i = 1:numel(varargin)
    if ischar(varargin{i}) && strcmpi(varargin{i}, 'PlotRange')
        if i < numel(varargin)
            PlotRange = varargin{i + 1};
            PlotRangeFlag=true;
            break
        end
    end
end

if and(PlotRangeFlag,PlotRangeSocSensorFlag)
    PlotRangeSocSensorFlag=false;
    warning("Plot range will based on the input ranges")
end

% Set PlotRangeSocSensorFlag if true, using SocSensor data
if PlotRangeSocSensorFlag
    infofile = fullfile('Info', strcat('Info', '_', fname));
    load(infofile, 'norm_TT', 'event', 'scale_factor')
    SessionRange = [norm_TT(event == "session start"), norm_TT(event == "session end")];
    [~, ll] = min(abs(NormTime - SessionRange(1)));
    [~, lh] = min(abs(NormTime - SessionRange(2)));
    PlotRange = ll:lh;
elseif PlotRangeFlag
    infofile = fullfile('Info', strcat('Info', '_', fname));
    load(infofile, 'scale_factor')
    PlotRange1=PlotRange;
    [~, ll] = min(abs(NormTime - PlotRange1(1)/scale_factor));
    [~, lh] = min(abs(NormTime - PlotRange1(2)/scale_factor));
    PlotRange = ll:lh;

end

PerTimeOverThres1=zeros(length(ParLabel),length(ParLabel));
PerTimeOverThres2=nan(length(ParLabel),length(ParLabel));
PerTimeOverThres=zeros(length(ParLabel),1);
p1=strings(length(ParLabel),1);
p2=strings(length(ParLabel),1);
pairs=strings(length(ParLabel),1);

% MyOrder
S4label=false(length(MyOrder),1);
for i=1:length(MyOrder)
    FN=fieldnames(AlgDataReal);
    for j=1:length(FN)
        if j==1
            DataReal=AlgDataReal.(FN{j}){i,1};
        else
            DataReal=[DataReal;AlgDataReal.(FN{j}){i,1}];
        end
    end

    if PlotRangeSocSensorFlag
        % DataPsu=DataPsu(:,PlotRange);
        DataReal=DataReal(:,PlotRange);
    end
    windowsize=(5/0.04);
    idx=1:windowsize:length(DataReal);
    if idx(end) ~=length(DataReal)
        idx=[idx,length(DataReal)+1];
    end
    DataAves=zeros(1,size(DataReal,1));
    for j=1:(length(idx)-1)
        idxend=idx(j)+windowsize-1;
        if idxend>length(DataReal)
            idx(j)=length(DataReal)-windowsize+1;
            idxend=length(DataReal);
        end
        DataAve=mean(DataReal(:,idx(j):idxend)');
        DataAves=[DataAves;DataAve];
    end

    [prediction, ~] = predict(Model, DataAves);
    bint=zeros(1,length(DataReal));
    for j=1:(length(idx)-1)
        idxend=idx(j)+windowsize-1;
        if idxend>length(DataReal)
            idx(j)=length(DataReal)-windowsize+1;
            idxend=length(DataReal);
        end


        bint(idx(j):idxend)=repmat(prediction(j),1,length(idx(j):idxend));

    end

    PerTimeOverThres(i)=sum(bint)/length(bint);
    if MyOrder(i,1)>MyOrder(i,2)
        p1(i)=ParLabel(MyOrder(i,1));
        p2(i)=ParLabel(MyOrder(i,2));

        pairs(i)=strcat(ParLabel(MyOrder(i,1)),'_',ParLabel(MyOrder(i,2)));
        PerTimeOverThres2(MyOrder(i,1),MyOrder(i,2))=PerTimeOverThres(i);

    else
        p1(i)=ParLabel(MyOrder(i,2));
        p2(i)=ParLabel(MyOrder(i,1));
        pairs(i)=strcat(ParLabel(MyOrder(i,2)),'_',ParLabel(MyOrder(i,1)));
        PerTimeOverThres2(MyOrder(i,2),MyOrder(i,1))=PerTimeOverThres(i);

    end

    PerTimeOverThres1(MyOrder(i,2),MyOrder(i,1))=PerTimeOverThres(i);
    PerTimeOverThres1(MyOrder(i,1),MyOrder(i,2))=PerTimeOverThres(i);
    if or(ParLabel(MyOrder(i,2))=='S4',ParLabel(MyOrder(i,1))=='S4')
        S4label(i)=true;

    end

end
% Pairs=[p1,p2];
varargout{1} = PerTimeOverThres;
varargout{2} = pairs;
varargout{3} = PerTimeOverThres1;
varargout{4} = PerTimeOverThres2;

if PlotType=="NT"
    GenerateNetworkPlot(PerTimeOverThres1,ParLabel,session,'Excludeperc',0.02)

elseif PlotType=="IM"
    figure
    h=heatmap(cellstr(ParLabel),cellstr(ParLabel),PerTimeOverThres1,'MissingDataColor', 'w','GridVisible', 'off','CellLabelColor', 'None');
    set(findall(gcf,'-property','FontSize'),'FontSize',18)
    % h.ColorLimits=[0.1,0.3];
    title(session)

else

    % warning("Wrong Plots types. No plot will generated")
end

end
