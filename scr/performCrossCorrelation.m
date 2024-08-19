function CC_data = performCrossCorrelation(OriData, timeStep, CC_CONFIG)
    % performCrossCorrelation - Performs cross-correlation analysis on prepared data
    %
    % Inputs:
    %   OriData - Struct containing prepared data for each session
    %   timeStep - Time step for analysis
    %   CC_CONFIG - Configuration struct for cross-correlation analysis
    %
    % Output:
    %   CC_data - Struct containing cross-correlation analysis results for each session
    
    CC_data = struct();
    sessionNames = fieldnames(OriData);
    for i = 1:numel(sessionNames)
        fname = sessionNames{i};
        filtOriData = OriData.(fname);
        
        % xcrossSlidingWin function should be defined in your src folder
        [ccori, name1] = xcrossSlidingWin(filtOriData(:,2:end), timeStep, CC_CONFIG.WINDOW_SIZE, ...
            CC_CONFIG.STEP_SIZE, CC_CONFIG.WCOEF, 'removegravityflag', CC_CONFIG.REMOVE_GRAVITY, ...
            'normflag', CC_CONFIG.NORM_FLAG, 'windownormflag', CC_CONFIG.WINDOW_NORM_FLAG, ...
            'scaleopt', CC_CONFIG.SCALE_OPT);
        
        CC_data.(fname).(name1) = ccori;
        fprintf('Finished Cross-Correlation for %s\n', fname);
    end
end