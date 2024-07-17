function [EvaluationMetric1, evaluationTable, varargout] = modelBaggingTrain(fMat, classLabels, groups, SessionPariLabel, varargin)
% MODELBAGGINGTRAIN Trains a bagging ensemble model and evaluates it using cross-validation.
%
% INPUTS:
%   - fMat (matrix): Feature matrix where rows are samples and columns are features.
%   - classLabels (vector): Class labels corresponding to the samples in fMat.
%   - groups (cell array): Indices of sessions for cross-validation.
%   - SessionPariLabel (cell array): Session and pair labels for the samples.
%   - varargin: Optional parameters including:
%       - 'SavedModel' (cell array): Pre-trained models.
%       - 'template' (object): Template for the type of learner used in the ensemble.
%       - 'NumLearningCycles' (int): Number of learning cycles for the ensemble method (default: 60).
%
% OUTPUTS:
%   - EvaluationMetric1 (matrix): Evaluation metrics for each cross-validation fold.
%   - evaluationTable (table): Table of evaluation metrics with descriptive names.
% OUTPUTS (Optional):
%   - Model (cell array): Trained ensemble models for each fold (optional).
%
% The function trains a bagging ensemble classifier using the specified template and
% number of learning cycles. It performs cross-validation to evaluate the model's
% performance, calculating various metrics including AUC and confusion matrix-based metrics.

% Default values for optional parameters
SavedModelFlag = false;
template = [];
NumLearningCycles = 60;

% Parse optional parameters
for i = 1:numel(varargin)
    if ischar(varargin{i}) && strcmpi(varargin{i}, 'SavedModel')
        if i < numel(varargin)
            trees = varargin{i + 1};
            SavedModelFlag = true;
            break
        end
    end
end

for i = 1:numel(varargin)
    if ischar(varargin{i}) && strcmpi(varargin{i}, 'template')
        if i < numel(varargin)
            template = varargin{i + 1};
            SavedModelFlag = false;
            break
        end
    end
end

for i = 1:numel(varargin)
    if ischar(varargin{i}) && strcmpi(varargin{i}, 'NumLearningCycles')
        if i < numel(varargin)
            NumLearningCycles = varargin{i + 1};
            break
        end
    end
end

% Load session names from the information file
load(fullfile('Info', 'allinfostr'), 'SessionNames');

% Initialize variables
numGroups = size(groups, 1);
aucs = zeros(numGroups, 2);
EvaluationMetric = zeros(numGroups, 11); % Adjusted size to match all calculated metrics

% Loop through each cross-validation group
for k = 1:numGroups
    parSel = groups{k};
    sel = false(size(classLabels));
    for j = 1:length(parSel)
        sel = or(sel, SessionPariLabel(:, 1) == SessionNames(parSel(j)));
    end

    % Split data into training and testing sets
    trainData = fMat(~sel, :);
    trainLabels = classLabels(~sel);

    % Train bagging ensemble model if not using a saved model
    if ~SavedModelFlag
        trees{k} = fitcensemble(trainData, trainLabels, ...
            'Method', 'Bag', ...
            'NumLearningCycles', NumLearningCycles, ...
            'Learners', template);
    end

    % Predict using the trained model
    testData = fMat(sel, :);
    testLabels = classLabels(sel);
    [predictions, modelScores] = predict(trees{k}, testData);
    modelScores2 = [modelScores(:, 2), modelScores(:, 1)];
    
    % Calculate AUC for both classes
    [~, ~, ~, AUC1] = perfcurve(testLabels, modelScores(:, 2), 1);
    [~, ~, ~, AUC2] = perfcurve(testLabels, modelScores2(:, 2), 0);
    aucs(k, :) = [AUC1, AUC2]; % Store AUC for this fold

    % Aggregate predictions and true labels
    if k == 1
        realLabelALL = testLabels;
        predLabelALL = predictions;
    else
        realLabelALL = [realLabelALL; testLabels];
        predLabelALL = [predLabelALL; predictions];
    end

    % Confusion matrix
    confusion_matrix = confusionmat(testLabels, double(predictions));
    
    % Extract values from the confusion matrix
    TN = confusion_matrix(1, 1);
    FP = confusion_matrix(1, 2);
    FN = confusion_matrix(2, 1);
    TP = confusion_matrix(2, 2);
    
    % Calculate evaluation metrics
    EvaluationMetric(k, 1) = TN / (TN + FN);  % Specificity
    EvaluationMetric(k, 2) = TP / (TP + FP);  % Precision
    EvaluationMetric(k, 3) = TN / (TN + FP);  % Negative Predictive Value
    EvaluationMetric(k, 4) = TP / (TP + FN);  % Sensitivity (Recall)
    EvaluationMetric(k, 5) = TN / (TN + FP);  % Accuracy for negative class
    EvaluationMetric(k, 6) = TN / (TN + FN);  % Accuracy for positive class
    EvaluationMetric(k, 7) = 2 * (EvaluationMetric(k, 1) * EvaluationMetric(k, 3)) / (EvaluationMetric(k, 1) + EvaluationMetric(k, 3));  % F1 Score for negative class
    EvaluationMetric(k, 8) = 2 * (EvaluationMetric(k, 2) * EvaluationMetric(k, 4)) / (EvaluationMetric(k, 2) + EvaluationMetric(k, 4));  % F1 Score for positive class
    EvaluationMetric(k, 9) = (TP + TN) / (TP + TN + FP + FN);  % Overall Accuracy
    EvaluationMetric(k, 10) = (EvaluationMetric(k, 3) + EvaluationMetric(k, 6)) / 2;  % Balanced Accuracy
    EvaluationMetric(k, 11) = AUC1;  % AUC for positive class
end

% Transpose and scale EvaluationMetric for output
EvaluationMetric1 = EvaluationMetric';
EvaluationMetric1(1:(end-1), :) = 100 * EvaluationMetric1(1:(end-1), :);

% Generate a table for EvaluationMetric
metricNames = {'Specificity', 'Precision', 'Negative Predictive Value', ...
    'Sensitivity', 'Accuracy (Negative Class)', 'Accuracy (Positive Class)', ...
    'F1 Score (Negative Class)', 'F1 Score (Positive Class)', ...
    'Overall Accuracy', 'Balanced Accuracy', 'AUC'};
evaluationTable = array2table(EvaluationMetric1', 'VariableNames', metricNames);

% Display the table
disp(evaluationTable);

% Plot confusion matrix
figure;
cm = confusionchart(realLabelALL, predLabelALL);
cm.RowSummary = 'row-normalized';
cm.ColumnSummary = 'column-normalized';
set(gca, 'FontSize', 20);

Model = trees;

% Handle varargout for optional outputs
nargoutchk(2, 3);
optionalOutputs = {Model};
for k = 1:nargout-2
    varargout{k} = optionalOutputs{k};
end

end
