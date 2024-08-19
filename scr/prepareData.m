function [OriData, ParLabels] = prepareData(SessionNames, CONFIG)
    % prepareData - Prepares data for all sessions
    %
    % Inputs:
    %   SessionNames - Cell array of session names
    %   CONFIG - Configuration struct containing sensor type, side, and filter settings
    %
    % Outputs:
    %   OriData - Struct containing prepared data for each session
    %   ParLabels - Struct containing participant labels for each session
    
    OriData = struct();
    ParLabels = struct();
    for i = 1:size(SessionNames, 1)
        session = SessionNames{i};
        fname = regexprep(session, ' ', '_');
        
        % DataPrepare function should be defined in your src folder
        [filtOriData, ParLabel] = DataPrepare(session, CONFIG.SENSOR_TYPE, CONFIG.SIDE, CONFIG.FILTER_CUTOFF);
        
        ParLabels.(fname) = ParLabel;
        OriData.(fname) = filtOriData;
        
        fprintf('Finished processing %s\n', session);
    end
end