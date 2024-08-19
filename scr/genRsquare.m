function resultsTable = genRsquare(Alg, AlgName, grounTruth)
% GENRSQUARE Computes the R-squared and p-value for each algorithm's output against the ground truth.
%
% INPUTS:
%   - Alg (matrix): Algorithm output values, where each column represents a different algorithm.
%   - AlgName (cell array of strings): Names of the algorithms corresponding to the columns of Alg.
%   - grounTruth (vector): Ground truth values to compare against.
%
% OUTPUTS:
%   - resultsTable (Table): A table storing R-squared and p-value for each algorithm.
%
% Example:
%   genRsquare(AlgValues, {'Alg1', 'Alg2', 'Alg3'}, groundTruthValues)

% Initialize a structure to store R-squared and p-values
rsquare = struct;

% Initialize arrays to store results for table
algNames = cell(length(AlgName), 1);
rSquareValues = zeros(length(AlgName), 1);
pValues = zeros(length(AlgName), 1);

% Loop through each algorithm
for i = 1:length(AlgName)
    dy = Alg(:, i);  % Extract the output values of the current algorithm
    dx = grounTruth; % Ground truth values
    
    % Perform regression analysis
    [~, ~, ~, ~, stats] = regress(dy, [ones(size(dx)), dx]);
    
    % Store R-squared and p-value in the structure
    rsquare.(AlgName{i}) = [stats(1), stats(3)];
    
    % Store values for table
    algNames{i} = AlgName{i};
    rSquareValues(i) = stats(1);
    pValues(i) = stats(3);
end

% Create a table with the results
resultsTable = table(algNames, rSquareValues, pValues, ...
    'VariableNames', {'Algorithm', 'R_Square', 'P_Value'});

% Display the table
disp('Results Table:');
disp(resultsTable);

end