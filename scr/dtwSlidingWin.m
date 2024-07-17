function [dtwori, name] = dtwSlidingWin(x, ts, windowsize, stepsize, wcoef, varargin)
% DTWSLIDINGWIN Computes pairwise Dynamic Time Warping (DTW) of input x in a sliding window manner.
%
% Inputs:
% x - Data matrix (time series), where each column is a different signal.
% ts - Sampling time interval.
% windowsize - Size of the sliding window (in the same units as ts).
% stepsize - Step size for the sliding window (in the same units as ts).
% wcoef - Maximum lag setting in DTW (percentage of windowsize).
% varargin - Additional options specified as 'Name', value pairs:
%            'distmetric' (string) - Distance metric for DTW ('euclidean', 'absolute', 'squared', 'symmkl'), default is 'euclidean'.
%            'TimeScramble' (bool) - Flag to indicate if time scrambling is required, default is false.
%            'removeGravityFlag' (bool) - Flag to indicate if gravity should be removed, default is false.
%            'normFlag' (bool) - Flag to indicate if global normalization is required, default is true.
%            'windowNormFlag' (bool) - Flag to indicate if window normalization is required, default is true.
%
% Outputs:
% dtwori - Cell array containing the pairwise windowed DTW results.
% name - Name of the resulting data based on applied options.
%
% Example:
% [dtwori, name] = dtwSlidingWin(data, 0.04, 5, 2.5, [0.2, 0.5], 'distmetric', 'euclidean')

% List of valid distance metrics
distmetricList = ["euclidean", "absolute", "squared", "symmkl"];
distmetric = 'euclidean';

% Parse varargin for distance metric option
for i = 1:numel(varargin)
    if ischar(varargin{i}) && strcmpi(varargin{i}, 'distmetric')
        if i < numel(varargin)
            distmetric = varargin{i + 1};
            break
        end
    end
end

% Validate distance metric
if ~ismember(distmetric, distmetricList)
    error('Distance metric option does not exist')
end

% Initialize optional flags with default values
TimeScrambleFlag = false;
removeGravityFlag = false;
normFlag = true;
windowNormFlag = true;

% Parse varargin for additional options
for i = 1:numel(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case 'timescramble'
                if i < numel(varargin)
                    TimeScrambleFlag = varargin{i + 1};
                end
            case 'removegravityflag'
                if i < numel(varargin)
                    removeGravityFlag = varargin{i + 1};
                end
            case 'normflag'
                if i < numel(varargin)
                    normFlag = varargin{i + 1};
                end
            case 'windownormflag'
                if i < numel(varargin)
                    windowNormFlag = varargin{i + 1};
                end
        end
    end
end

% Apply time scrambling if required
if TimeScrambleFlag
    y = TimeScramble(x);
else
    y = x;
end

% Remove gravity if required
if removeGravityFlag
    x = x - 1;
    y = y - 1;
end

% Normalize data if required
if normFlag
    x = normalize(x, 1);
    y = normalize(y, 1);
end

% Convert windowsize and stepsize to sample points
windowsize = round(windowsize / ts);
stepsize = round(stepsize / ts);

% Generate pairwise combinations of signals
wtOrder = nchoosek(1:size(x, 2), 2);
fprintf('Number of DTW calculation: %d\n', size(wtOrder, 1));
AA = wtOrder(:, 1);
BB = wtOrder(:, 2);

% Initialize cell array to store DTW results
dtwori = cell(size(AA, 1), 1);
w = round(windowsize * wcoef);

% Parallel loop for DTW calculations
parfor ioo = 1:size(AA, 1)
    DistallN = zeros(1, length(x(:, 1)));

    for io = 1:length(wcoef)
        idx = 1:stepsize:length(x(:, 1));
        if idx(end) ~= length(x(:, 1))
            idx = [idx, length(x(:, 1)) + 1];
        end

        dist = 0;
        for i = 1:(length(idx) - 1)
            idxend = idx(i) + windowsize - 1;
            if idxend > length(x(:, 1))
                idx(i) = length(x(:, 1)) - windowsize + 1;
                idxend = length(x(:, 1));
            end

            s1 = x(idx(i):idxend, AA(ioo));
            s2 = y(idx(i):idxend, BB(ioo));

            if windowNormFlag
                s1 = normalize(s1);
                s2 = normalize(s2);
            end
            if w(io) ~= 0
                dist = [dist; dtw(s1, s2, w(io), distmetric)];
            else
                dist = [dist; pdist2(s1', s2', distmetric)];
            end
        end
        dist(1) = [];

        distallN = zeros(1, length(x(:, 1)));
        nosteps = round(windowsize / stepsize);

        for i = 1:length(dist)
            if i < windowsize / stepsize
                distallN(idx(i):(idx(i + 1) - 1)) = mean(dist(1:i));
            elseif (length(dist) - i) < (windowsize / stepsize - 1)
                distallN(idx(i):(idx(i + 1) - 1)) = mean(dist(i:end));
            else
                distallN(idx(i):(idx(i + 1) - 1)) = mean(dist((i - nosteps + 1):i));
            end
        end

        DistallN = [DistallN; distallN];
    end
    DistallN(1, :) = [];
    dtwori{ioo, 1} = DistallN;
    fprintf('Finished calculation of DTW between %d & %d\n', AA(ioo), BB(ioo));
end

% Construct the name based on applied options
name = "dtw";
if removeGravityFlag
    name = strcat(name, '_NOg');
end
if normFlag
    name = strcat('N', name);
end
if windowNormFlag
    name = strcat('WN', name);
end

name = strcat(name, '_W', num2str(windowsize), 'S', num2str(stepsize));

end