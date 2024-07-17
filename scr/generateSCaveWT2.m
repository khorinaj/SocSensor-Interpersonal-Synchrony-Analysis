function [scaleAve, wtOrder, Period, CoiRange] = generateSCaveWT2(x, ts, periodLimit, normflag, scRanges)
% GENERATESCAVEWT2 Prepares and computes pairwise scale-averaged wavelet transform and coherence.
% Inputs:
% x - Data matrix (time series), where each column is a different signal.
%     Pairwise wavelet analysis is generated according to columns.
% ts - Sampling time interval.
% periodLimit - Two-element vector specifying the lower and upper period limits for the wavelet transform.
% normflag - Boolean flag indicating whether to normalize the data (true/false).
% scRanges - nx2 Matrix where Column 1 indicate lower limit and Column2
%            upper limit of period range used for averaging
%            each row specifies a different scale range for the scale-averaged calculations.
%            
%
% Outputs:
% scaleAve - Struct containing the scale-averaged wavelet transform and coherence.
% wtOrder - Matrix of pairs of indices indicating combinations of signals.
% Period - Vector of periods corresponding to the wavelet transform.
% CoiRange - Range of cone of influence, indicating reliable regions in the wavelet transform.
%
% Example:
% [scaleAve, wtOrder, Period, CoiRange] = generateSCaveWT2(data, 0.01, [[0.5, 5];[5,15]], true, scaleRanges)
%
% Note: This function relies on the wavelet-coherence-master package.

% Add the necessary path for the wavelet-coherence functions
currentFolder = pwd;
addpath(fullfile(currentFolder, 'scr/wavelet-coherence-master'));

% Extract scale ranges from varargin
Nosc = size(scRanges, 1);

% Normalize data if required
if normflag
    x = normalize(x, 1);
end

% Calculate the number of combinations of signals
wtOrder = nchoosek(1:size(x, 2), 2);
fprintf('Number of XWT & WCT calculations: %d\n', size(wtOrder, 1));
AA = wtOrder(:, 1);
BB = wtOrder(:, 2);

% Define period limits and time vector
tl = periodLimit(1);
th = periodLimit(2);
t = 0:ts:((length(x) - 1) * ts);

% Perform an initial wavelet transform to determine Period and coi range
[~,~,~,~,~,Period,~,coi,~] = xwtwct([t', x(:,1)], [t', x(:,2)], 'S0', tl, 'MaxScale', th);
Period = Period';
coi_range = find(coi > periodLimit(2));
CoiRange = coi_range(1);

% Initialize cell arrays to store results
xwALLs = cell(length(AA), Nosc);
wcohALLs = cell(length(AA), Nosc);

% Parallel loop for wavelet transform and coherence calculations
parfor io = 1:length(AA)
    % Initialize cell arrays for original wavelet and coherence data
    xwori = cell(1, 1);
    wcohori = cell(1, 1);

    % Perform wavelet transform and coherence for the signal pair
    [xwori{1,1}, wcohori{1,1}, ~, ~, ~, ~, ~, ~] = xwtwct([t', x(:, AA(io)) - 1], [t', x(:, BB(io)) - 1], 'S0', tl, 'MaxScale', th);

    % Initialize cell arrays for scale-averaged data
    xwALL = cell(1, Nosc);
    wcohALL = cell(1, Nosc);

    % Calculate scale-averaged wavelet and coherence for each scale range
    for i = 1:Nosc
        sc = scRanges(i, :);
        [~, b1] = min(abs(Period - sc(1)));
        [~, b2] = min(abs(Period - sc(2)));
        scaleRange = b1:b2;

        % Generate scale-averaged wavelet transform
        [~, sc_ave] = generateSCave('xw', scaleRange, xwori, 1, periodLimit);
        xwALL{1, i} = sc_ave{1, 1};

        % Generate scale-averaged wavelet coherence
        [~, sc_ave2] = generateSCave('wcoh', scaleRange, wcohori, 1, periodLimit);
        wcohALL{1, i} = sc_ave2{1, 1};
    end

    % Store results in cell arrays
    [xwALLs{io, :}] = xwALL{:};
    [wcohALLs{io, :}] = wcohALL{:};

    fprintf('Finished calculation of XWT & WCT between %d & %d\n', AA(io), BB(io));
end

% Create a structure to store scale-averaged results
scaleAve = struct;
for i = 1:Nosc
    sc = scRanges(i, :);
    [~, b1] = min(abs(Period - sc(1)));
    [~, b2] = min(abs(Period - sc(2)));
    my_field = strcat('xw', 'Scave', num2str(b1), '_', num2str(b2));
    my_field2 = strcat('wcoh', 'Scave', num2str(b1), '_', num2str(b2));
    scaleAve.(my_field) = xwALLs(:, i);
    scaleAve.(my_field2) = wcohALLs(:, i);
end

% Clear temporary variables
clear xwori wcohori

end