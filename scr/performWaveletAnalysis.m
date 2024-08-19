function WA_data = performWaveletAnalysis(OriData, timeStep, WA_CONFIG)
    % performWaveletAnalysis - Performs wavelet analysis on prepared data
    %
    % Inputs:
    %   OriData - Struct containing prepared data for each session
    %   timeStep - Time step for analysis
    %   WA_CONFIG - Configuration struct for wavelet analysis
    %
    % Output:
    %   WA_data - Struct containing wavelet analysis results for each session
    
    WA_data = struct();
    sessionNames = fieldnames(OriData);
    PERIOD_LIMIT=[0.10861, 104.98];
    for i = 1:numel(sessionNames)
        fname = sessionNames{i};
        filtOriData = OriData.(fname);
        
        % generateSCaveWT2 function should be defined in your src folder
        [OriScaleAve, ~, ~, ~] = generateSCaveWT2(filtOriData(:,2:end), timeStep, ...
            PERIOD_LIMIT, WA_CONFIG.NORM_FLAG, WA_CONFIG.SCALE_RANGE);
        
        WA_data.(fname) = OriScaleAve;
        fprintf('Finished Wavelet Analysis for %s\n', fname);
    end
end