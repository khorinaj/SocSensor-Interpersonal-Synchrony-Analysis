function [StaResults, fullAlgList] = genR4CombinedFeatures(Alg, AlgName1, grounTruth, groups, NofeatureCombine, SessionPariLabel)
% GENR4COMBINEDFEATURES Generates R-squared values for combined features.
%
% This function evaluates the performance of different combinations of features
% from multiple algorithms by calculating the weight of on training data and applied weight on test data to find 
%  R-squared value of the regression for both training data set model for each combination. 
% It splits the data into training and test sets based on the provided groups to avoid data leakage.
%
% INPUTS:
%   - Alg (matrix): Algorithm output values, where each column represents a different algorithm.
%   - AlgName1 (strings): Names of the algorithms corresponding to the columns of Alg.
%   - grounTruth (vector): Ground truth values to compare against.
%   - groups (cell array): A cell array where each cell contains the indices of sessions for one fold.
%   - NofeatureCombine (int): Number of features to combine in each evaluation.
%   - SessionPariLabel (cell array): A cell array where each row represents a session and pair label.
%
% OUTPUTS:
%   - StaResults (matrix): Statistical results for each feature combination, including mean and standard deviation of training and test R-squared values.
%                          This is sorted according to the test results
%   - fullAlgList (strings): List of feature combinations.

% Extract feature matrix and ground truth values
f = Alg;
dy = grounTruth;

% Load session names
load(fullfile('Info', 'allinfostr'), 'SessionNames');

% Number of folds
foldnum = length(groups);

% Generate all combinations of features
Coms = nchoosek(1:size(f, 2), NofeatureCombine);
fprintf('Number of Combinition: %d\n', size(Coms, 1));

% Initialize result matrices
TrainingResults = zeros(size(Coms, 1), foldnum);
TestResults = zeros(size(Coms, 1), foldnum);
fullAlgList = cell(size(Coms, 1), 1);

% Loop through each feature combination
for j = 1:size(Coms, 1)
    % Select features for the current combination
    dx = f(:, Coms(j, :));
    fullAlgList{j, 1} = strjoin(AlgName1(Coms(j, :)), ', ');

    % Loop through each fold
    for k = 1:foldnum
        % Select sessions for the current fold
        parSel = groups{k};
        sel = false(size(dy));
        for jj = 1:length(parSel)
            sel = or(sel, SessionPariLabel(:, 1) == SessionNames(parSel(jj)));
        end

        % Split data into training and test sets
        Xtrain = dx(~sel, :).^2;
        Xtest = dx(sel, :);
        Ytrain = dy(~sel).^2;
        Ytest = dy(sel);

        % Fit a generalized linear model (GLM)
        mm = fitglm(Xtrain, Ytrain);

        % Extract weights from the GLM coefficients
        weight = mm.Coefficients.Estimate(2:end);

        % Calculate R-squared for training data
        Xtrain = Xtrain * weight;
        [~, ~, ~, ~, stats] = regress(Ytrain, [ones(size(Xtrain, 1), 1), Xtrain]);
        TrainingResults(j, k) = stats(1);

        % Calculate R-squared for test data
        Xtest = Xtest * weight;
        [~, ~, ~, ~, stats] = regress(Ytest, [ones(size(Xtest, 1), 1), Xtest]);
        TestResults(j, k) = stats(1);
    end
    fprintf('Finish %d combinitions \n', j);
    % disp(j)
end

% Calculate mean and standard deviation of training and test R-squared values
StaResults = [mean(TrainingResults, 2), std(TrainingResults, [], 2), mean(TestResults, 2), std(TestResults, [], 2)];

% Sort results by mean test R-squared value in descending order
[~, idx] = sort(StaResults(:, 3), 'descend');
StaResults = StaResults(idx, :);
fullAlgList = fullAlgList(idx);

end