function [VideoScore, AlgValueAverage, AlgrithmList, SessionPariLabel,varargout] = ...
          ExtractAlgValuesFromTimePoints(SyncData, ParLabels, Alg)
% EXTRACTALGVALUESFROMTIMEPOINTS2 Extracts algorithm values from time points.
%
% INPUTS:
%   - SyncData (struct): Synchronized data for all sessions.
%   - ParLabels (struct): Participant labels for all sessions.
%   - Alg (struct): Algorithm data for all sessions. This could be wavelet analysis, 
%                   cross correlation and dtw generated in SimilarityAnalysis script
%
% OUTPUTS (Required):
%   - VideoScore n x 1 (matrix): Video scores (ground truth data marked by researcher).
%   - AlgrithmList 1 x m (strings): List of algorithms with m different algorithms provided in Alg.
%   - AlgValueAverage n x m (matrix): Averaged algorithm values at for 5s window centered at each video scoring time.
%   - SessionPariLabel  n x 3 (cell array): Informantion of Session, pair labels and time points selected from which algorithm for each video score.
%
% OUTPUTS (Optional):
%   - TimeValues (matrix): Time values associated with the extracted data.
%   - AlgValueSingle (matrix): Algorithm values at each video scoring time.
%   - AlgValueEvery (matrix): Algorithm values at each data point for 5s window centered at each video scoring time.
%   - VideoScoreEvery (matrix):  Video scores corresponded to AlgValueEvery.

% Read Video scores and Reshape
RawScoreMatrix = readmatrix(fullfile('Info', 'Student_Score.xlsx'), 'Sheet', 'Sheet3');
RawScoreTable = readtable(fullfile('Info', 'Student_Score.xlsx'), 'Sheet', 'Sheet3');
RawScoreMatrix = RawScoreMatrix(3:end, :);
RawScoreTable = RawScoreTable(2:end, :);
ScoreSession = string(RawScoreTable.Var1);
ScorePair = string(RawScoreTable.Var4);

T18Att = RawScoreMatrix(:, 8:6:115);
T18Motor = RawScoreMatrix(:, 10:6:115);
T18Prox = RawScoreMatrix(:, 11:6:115);
T18Overall = RawScoreMatrix(:, 12:6:115);
types = ["xwHighf", "wcohHighf", "wcohLowf"];

set = [1:6; 7:12; 13:18];
for i = 1:3
    MethodExtract = repmat(types(i), 6, 1);
    [RT6Att, ~] = ReshapeInfoMatrix2(T18Att(:, set(i, :)), ScoreSession, ScorePair, MethodExtract);
    [RT6Motor, ~] = ReshapeInfoMatrix2(T18Motor(:, set(i, :)), ScoreSession, ScorePair, MethodExtract);
    [RT6Prox, ~] = ReshapeInfoMatrix2(T18Prox(:, set(i, :)), ScoreSession, ScorePair, MethodExtract);
    [RT6Overall, info] = ReshapeInfoMatrix2(T18Overall(:, set(i, :)), ScoreSession, ScorePair, MethodExtract);
    if i == 1
        CleanScoreM = [RT6Att, RT6Motor, RT6Prox, RT6Overall];
    else
        CleanScoreM = [CleanScoreM, [RT6Att, RT6Motor, RT6Prox, RT6Overall]];
    end
end
ScoreMatrix3Alg = CleanScoreM;
SessionLabel4Score = info(:, 1);
PairLabel4Score = info(:, 2);

% Read Time Points
load(fullfile('Info', 'VideoScoreTimePoints.mat'), 'TimePoints', 'SessionsLabel', 'PairsLabel')
PairLabel4Time = PairsLabel;
SessionLabel4Time = SessionsLabel;

load(fullfile('Info', 'allinfostr'), 'allinfostr')
count = 0;

for SessionNo = 1:size(allinfostr, 1)
    if allinfostr(SessionNo, 1) == string(0)
        continue
    end

    session = allinfostr(SessionNo, 4);
    fsession = regexprep(session, ' ', '_');
    NormTime = SyncData.(fsession)(:, 1);
    DataSize = length(ParLabels.(fsession));
    Alg4Session = Alg.(fsession);

    % Extract information for each session
    SessionSel4score = SessionLabel4Score == session;
    ScoreMatrix3AlgES = ScoreMatrix3Alg(SessionSel4score, :);
    SessionLabel4ScoreES = SessionLabel4Score(SessionSel4score);
    PairLabel4ScoreES = strrep(PairLabel4Score(SessionSel4score), "'", "");
    [UniPairLabel4Score, ~] = unique(PairLabel4ScoreES);

    ParLabel = ParLabels.(regexprep(session, ' ', '_'));
    MyOrder = nchoosek(1:DataSize, 2);

    for PairNo = 1:length(UniPairLabel4Score)
        % disp(UniPairLabel4Score(PairNo))
        
        % Find the Pair in the algorithm's order
        PairStr = split(UniPairLabel4Score(PairNo), '-');
        P1 = PairStr{1, 1};
        P2 = PairStr{2, 1};
        Sel1 = and(ParLabel(MyOrder(:, 1)) == P1, ParLabel(MyOrder(:, 2)) == P2);
        Sel2 = and(ParLabel(MyOrder(:, 2)) == P1, ParLabel(MyOrder(:, 1)) == P2);
        AlgPairLoc = find(or(Sel1, Sel2));

        if isempty(AlgPairLoc)
            disp('Pair does not exist in Algorithm calculation! Skip')
            continue
        end

        % Reshape SCORE data for each session and each pair
        PairSel = PairLabel4ScoreES == UniPairLabel4Score(PairNo);
        ScoreMatrix3AlgESEP = ScoreMatrix3AlgES(PairSel, :);
        ScoreMatrix3AlgESEP = [ScoreMatrix3AlgESEP(:, 1:4); ScoreMatrix3AlgESEP(:, 5:8); ScoreMatrix3AlgESEP(:, 9:12)];

        TimesSelESEP = and(UniPairLabel4Score(PairNo) == PairLabel4Time, SessionLabel4Time == session);
        if sum(TimesSelESEP) == 0
            % disp(strcat(session, ': ', UniPairLabel4Score(PairNo)))
            continue
        end

        % Reshape TimePoints data for each session and each pair
        TimePointsESEP = TimePoints(TimesSelESEP, :);
        PairLabel4TimeESEP = PairLabel4Time(TimesSelESEP);
        SessionLabel4ESEP = SessionLabel4Time(TimesSelESEP);
        [TimePointsESEP, SessionPairLabelESEP] = ReshapeInfoMatrix(TimePointsESEP, SessionLabel4ESEP, PairLabel4TimeESEP);

        % Find location in norm time for each TimePoint
        TimePointsLocESEP = zeros(size(TimePointsESEP));
        for i = 1:length(TimePointsESEP)
            if TimePointsESEP(i) == 0
                TimePointsLocESEP(i) = 0;
            else
                [~, TimePointsLocESEP(i)] = min(abs(NormTime - TimePointsESEP(i)));
            end
        end

        % Extract values according to TimePointsLocESEP, repeat for each algorithm
        Algname = fieldnames(Alg4Session);

        SingleValue = zeros(length(TimePointsLocESEP), length(Algname));
        TimeValue = zeros(length(TimePointsLocESEP), length(Algname));
        AveValue = zeros(length(TimePointsLocESEP), length(Algname));
        EveryValue = zeros(length(TimePointsLocESEP) * 125, length(Algname));
        AlgrithmList = strings;
        AlgCount = 0;
        for AlgNo = 1:length(Algname)
            AlgData = Alg4Session.(Algname{AlgNo, 1}){AlgPairLoc, 1};
            AlgCount2 = 0;
            for ParameterNo = 1:size(AlgData, 1)
                AlgCount = AlgCount + 1;
                AlgCount2 = AlgCount2 + 1;
                if size(AlgData, 1) == 1
                    AlgrithmList(AlgCount) = Algname{AlgNo, 1};
                    AlgData1 = AlgData(ParameterNo, :);
                else
                    AlgrithmList(AlgCount) = strcat(Algname{AlgNo, 1}, '_', string(ParameterNo));
                    AlgData1 = AlgData(AlgCount2, :);
                end

                tempE = 0;
                temp = 0;
                for j = 1:length(TimePointsLocESEP)
                    TimeValue(j, AlgCount) = TimePointsLocESEP(j);
                    if TimePointsLocESEP(j) ~= 0
                        temp = [temp; mean(AlgData1((TimePointsLocESEP(j) - 62):(TimePointsLocESEP(j) + 62)))];
                        SingleValue(j, AlgCount) = max(AlgData1((TimePointsLocESEP(j) - 62):(TimePointsLocESEP(j) + 62)));
                        tempE = [tempE; AlgData1((TimePointsLocESEP(j) - 62):(TimePointsLocESEP(j) + 62))'];
                    else
                        temp = [temp; -1];
                        SingleValue(j, AlgCount) = -1;
                        tempE = [tempE; ones(125, 1) * -1];
                    end
                end
                temp(1) = [];
                AveValue(:, AlgCount) = temp;

                tempE(1) = [];
                EveryValue(:, AlgCount) = tempE;
            end
        end
        count = count + 1;
        if count == 1
            VideoScore = ScoreMatrix3AlgESEP;
            AlgValueSingle = SingleValue;
            AlgValueAverage = AveValue;
            SessionPariLabel = SessionPairLabelESEP;
            TimeValues = TimeValue;
            AlgValueEvery = EveryValue;
        else
            VideoScore = [VideoScore; ScoreMatrix3AlgESEP];
            AlgValueSingle = [AlgValueSingle; SingleValue];
            AlgValueAverage = [AlgValueAverage; AveValue];
            SessionPariLabel = [SessionPariLabel; SessionPairLabelESEP];
            TimeValues = [TimeValues; TimeValue];
            AlgValueEvery = [AlgValueEvery; EveryValue];
        end
    end
    % SessionNo
    disp(strcat(session, '_', 'finished'))
end
TimeValues = TimeValues(:, 1);

% Initialize an empty array to store the result
VideoScoreEvery = [];

% Repeat each element in the original array a specific number of times
for i = 1:length(VideoScore(:, 2))
    repeatedElement = repmat(VideoScore(i, 2), 125, 1);
    VideoScoreEvery = [VideoScoreEvery; repeatedElement];
end


Rej0nanSel = or(all(isnan(VideoScore), 2), all((VideoScore) == 0, 2));
VideoScore(Rej0nanSel, :) = [];
AlgValueSingle(Rej0nanSel, :) = [];
AlgValueAverage(Rej0nanSel, :) = [];
SessionPariLabel(Rej0nanSel, :) = [];
TimeValues(Rej0nanSel, :) = [];

Rej0nanSel = or(all(isnan(VideoScoreEvery), 2), all((VideoScoreEvery) == 0, 2));
VideoScoreEvery(Rej0nanSel, :) = [];
AlgValueEvery(Rej0nanSel, :) = [];

% Handle varargout for optional outputs
nargoutchk(4, 8);
optionalOutputs = {TimeValues, AlgValueSingle, AlgValueEvery, VideoScoreEvery};
for k = 1:nargout-4
    varargout{k} = optionalOutputs{k};
end
