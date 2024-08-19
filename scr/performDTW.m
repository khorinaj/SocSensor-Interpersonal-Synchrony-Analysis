function DTW_data = performDTW(OriData, timeStep, DTW_CONFIG)
    % performDTW - Performs Dynamic Time Warping analysis on prepared data
    %
    % Inputs:
    %   OriData - Struct containing prepared data for each session
    %   timeStep - Time step for analysis
    %   DTW_CONFIG - Configuration struct for DTW analysis
    %
    % Output:
    %   DTW_data - Struct containing DTW analysis results for each session
    
    DTW_data = struct();
    sessionNames = fieldnames(OriData);
    for i = 1:numel(sessionNames)
        fname = sessionNames{i};
        filtOriData = OriData.(fname);
        
        % dtwSlidingWin function should be defined in your src folder
        [dtwori, name] = dtwSlidingWin(filtOriData(:,2:end), timeStep, DTW_CONFIG.WINDOW_SIZE, ...
            DTW_CONFIG.STEP_SIZE, DTW_CONFIG.WCOEF, 'removegravityflag', DTW_CONFIG.REMOVE_GRAVITY, ...
            'normflag', DTW_CONFIG.NORM_FLAG, 'windownormflag', DTW_CONFIG.WINDOW_NORM_FLAG);
        
        DTW_data.(fname).(name) = dtwori;
        fprintf('Finished DTW for %s\n', fname);
    end
end
