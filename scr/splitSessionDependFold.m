function groups = splitSessionDependFold(numGroups, SessionPariLabel)
% SPLITSESSIONDEPENDDFOLD manually splits training and test data into groups, 
% ensuring that each group has a balanced number of sessions to avoid data leakage.
% It uses a "greedy by average" approach to distribute the sessions into groups
% such that the sum of each group is as close to the average target sum as possible.
%
% INPUTS:
%   - numGroups (int): The number of groups to split the sessions into.
%   - SessionPariLabel (cell array): A cell array where each row represents a session and pair label.
%
% OUTPUT:
%   - groups (cell array): A cell array of length numGroups, where each cell
%     contains the indices of the sessions assigned to that group.

% Load session names from the information file
load(fullfile('Info', 'allinfostr'), 'SessionNames');

% Initialize an array to count the number of pairs in each session
sumPAR = zeros(1, length(SessionNames));

% Group data according to sessions
for i = 1:length(SessionNames)
    session = SessionNames(i);
    sel = SessionPariLabel(:, 1) == session;
    sumPAR(i) = sum(sel);
end

% Calculate the proportion of pairs in each session relative to the smallest session
Parportion = sumPAR / min(sumPAR);

% Calculate the target sum for each group
targetSumPerGroup = sum(Parportion) / numGroups;

% Sort the session proportions in decreasing order
[sortedValues, idx] = sort(Parportion, 'descend');

% Initialize the groups and their corresponding sums
groups = cell(numGroups, 1);
groupSums = zeros(numGroups, 1);

% Greedy allocation of sessions to groups
for i = 1:length(sortedValues)
    % Find the group with the smallest current sum
    [~, groupIdx] = min(groupSums);

    % Add the current session to the chosen group
    groups{groupIdx} = [groups{groupIdx}, idx(i)];

    % Update the sum of the chosen group
    groupSums(groupIdx) = groupSums(groupIdx) + sortedValues(i);
end

% Calculate the total proportion
totalProportion = sum(Parportion);

% Display the sum of proportions for each group
for k = 1:numGroups
    groupElements = groups{k};
    elementsStr = sprintf('%d ', groupElements);
    groupProportion = sum(Parportion(groupElements));
    percentageOfData = (groupProportion / totalProportion) * 100;
    
    disp(['Fold ' num2str(k) ': Session used in Validation: ' elementsStr ...
          ' (' num2str(percentageOfData, '%.2f') '% of data)']);
end

end