function Baselinef = extractStatsticsFeature(OriData, ParLabels, TimeValues, SessionPairLabel)
% EXTRACTSTATSTICSFEATURE Extracts statistical features from synchronized data.
%
% INPUTS:
%   - OriData (struct): Original data for all sessions.
%   - ParLabels (struct): Participant labels for all sessions.
%   - TimeValues (matrix): Time points associated with the extracted data.
%   - SessionPairLabel (cell array): Session and pair labels.
%
% OUTPUT:
%   - Baselinef (matrix): Extracted statistical features.
%
% This function extracts statistical features from the original data based on
% the given time values and session-pair labels. The features are extracted
% from a window centered around the specified time points.

% Initialize the output matrix for statistical features
PariLabel = SessionPairLabel(:, 2);
Baselinef = zeros(length(PariLabel), 12);

% Loop through each pair label to extract features
for i = 1:length(PariLabel)
    % Split the pair label to get individual IDs
    splitStr2 = strsplit(PariLabel{i}, '-');
    
    % Retrieve synchronized data for the current session
    SyncData = OriData.(regexprep(SessionPairLabel{i, 1}, ' ', '_'));
    SyncData = SyncData(:, 2:end);
    
    % Retrieve participant IDs for the current session
    PersonID = ParLabels.(regexprep(SessionPairLabel{i, 1}, ' ', '_'));
    
    % Extract data for the two individuals in the pair
    Data1 = SyncData(:, PersonID == splitStr2{1});
    Data2 = SyncData(:, PersonID == splitStr2{2});
    
    % Define the data range centered around the specified time point
    dataRange = (TimeValues(i, 1) - 62):(TimeValues(i, 1) + 62);
    
    % Extract statistical features for the data range and store in Baselinef
    Baselinef(i, :) = [staset(Data1(dataRange), 1, 1), staset(Data2(dataRange), 1, 1)];
end
