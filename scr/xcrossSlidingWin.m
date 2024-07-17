function [ccori, name] = xcrossSlidingWin(x, ts, windowsize, stepsize, wcoef, varargin)
% XCROSSSLIDINGWIN Computes pairwise cross-correlation of input x in a sliding window manner.
%
% Inputs:
% x - Data matrix (time series), where each column is a different signal.
% ts - Sampling time interval.
% windowsize - Size of the sliding window (in the same units as ts).
% stepsize - Step size for the sliding window (in the same units as ts).
% wcoef -  maximum lag setting in CC (percentage of windowsize) 
% varargin - Additional options specified as 'Name', value pairs:
%            'TimeScramble' (bool) - Flag to indicate if time scrambling is required,defualt false.
%            'removeGravityFlag' (bool) - Flag to indicate if gravity should be removed,defualt false.
%            'normFlag' (bool) - Flag to indicate if globle normalization is required,defualt true.
%            'windowNormFlag' (bool) - Flag to indicate if window normalization is required,defualt false.
%            'scaleOpt' (string) - Option for scaling ('biased', 'unbiased', 'normalized', 'coeff') in xcorr Matalb function (Matalb documentation).
%
% Outputs:
% ccori - n Cell array containing the pariwise windowed cross-correlation results.
% name - Name of the resulting data based on applied options.
%
% Example:
% [ccori, name] = xcrossSlidingWin(data, 0.01, 100, 10, [0.5, 1, 2])

% Initialize optional flags with default values
TimeScrambleFlag = false;
removeGravityFlag = false;
normFlag = true;
windowNormFlag = true;
scaleopt = "none";

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
            case 'scaleopt'
                if i < numel(varargin)
                    scaleopt = varargin{i + 1};
                end
        end
    end
end

% Validate scale option
scaleoptList = ["biased", "unbiased", "normalized", "coeff"];
if scaleopt == "none"
    scaleoptflag = 0;
elseif ismember(scaleopt, scaleoptList)
    scaleoptflag = 1;
else
    error('Function normalization option does not exist')
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
fprintf('Number of CC calculation: %d\n', size(wtOrder, 1));
AA = wtOrder(:, 1);
BB = wtOrder(:, 2);

% Initialize cell array to store cross-correlation results
ccori = cell(size(AA, 1), 1);
w = round(windowsize * wcoef);

% Parallel loop for cross-correlation calculations
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

            dist = [dist; max(xcorr(s1, s2, w(io), scaleopt))];
        end
        dist(1) = [];

        distallN = zeros(1, length(x(:, 1)));
        nosteps = round(windowsize / stepsize);

        for i = 1:length(dist)
            if i < windowsize / stepsize
                distallN(idx(i):(idx(i+1)-1)) = mean(dist(1:i));
            elseif (length(dist) - i) < (windowsize / stepsize - 1)
                distallN(idx(i):(idx(i+1)-1)) = mean(dist(i:end));
            else
                distallN(idx(i):(idx(i+1)-1)) = mean(dist((i-nosteps+1):i));
            end
        end

        DistallN = [DistallN; distallN];
    end
    DistallN(1, :) = [];
    ccori{ioo, 1} = DistallN;
    fprintf('Finished calculation of CC between %d & %d\n', AA(ioo), BB(ioo));
end

% Construct the name based on applied options
name = "cc";
if removeGravityFlag
    name = strcat(name, '_NOg');
end
if normFlag
    name = strcat('N', name);
end
if windowNormFlag
    name = strcat('WN', name);
end
if scaleoptflag == 1
    name = strcat(name, '_func', num2str(scaleoptflag));
end
name = strcat(name, '_W', num2str(windowsize), 'S', num2str(stepsize));

end