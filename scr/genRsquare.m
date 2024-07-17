function rsquare=genRsquare(Alg, AlgName, grounTruth)
% GENRSQUARE Computes the R-squared and p-value for each algorithm's output against the ground truth.
%
% INPUTS:
%   - Alg (matrix): Algorithm output values, where each column represents a different algorithm.
%   - AlgName (strings): Names of the algorithms corresponding to the columns of Alg.
%   - grounTruth (vector): Ground truth values to compare against.
%
% OUTPUTS:
%   - rsquare (struct): A struct storing R-squared and p-value for each algorithm.
%
% Example:
%   genRsquare(AlgValues, {'Alg1', 'Alg2', 'Alg3'}, groundTruthValues)

% Initialize a structure to store R-squared and p-values
rsquare = struct;

% Loop through each algorithm
for i = 1:length(AlgName)
    dy = Alg(:, i);  % Extract the output values of the current algorithm
    dx = grounTruth; % Ground truth values

    % Perform regression analysis
    [~, ~, ~, ~, stats] = regress(dy, [ones(size(dx)), dx]);

    % Store R-squared and p-value in the structure
    rsquare.(AlgName(i)) = [stats(1), stats(3)];

    % Print the results for the current algorithm
    fprintf('%s: Rsquare: %.4f, p-value: %.4f\n', AlgName(i), stats(1), stats(3));
end

end
