%% Add functions to path
addpath('scr')
addpath('scr/wavelet-coherence-master')
%% Data preparation 
sensortype="ACC";
RLtype='R';
FiltCutoff=10;
%--------------------------------------------------------------------------
load(fullfile('Info','allinfostr'),'SessionNames')
OriData=struct;
ParLabels=struct;
% Example for all Sessions
for i=1:size(SessionNames,1)

      session=SessionNames(i);
      fname=regexprep(session, ' ', '_');
      
      % Prepare Sync data and Label for each session
      [filtOriData,ParLabel]=DataPrepare(session,sensortype,RLtype,FiltCutoff);
      % Save to struct for later use
      ParLabels.(fname)=ParLabel;
      OriData.(fname)=filtOriData;
      
    
      disp(strcat(session,'_','finished'))
end

%% Generate Wavelet analysis for all combinitions
% set normalization
normflag=false;
% set Period Ranges needs to be processed
%scaleRange=[[0.5,5];[5,15];[0.5,15]];
scaleRange=[0.5,15];
ts=0.04;
%--------------------------------------------------------------------------
periodLimit=[0.10861,104.98];
WA_data=struct;
% Example for all Sessions
for i=1:size(SessionNames,1)
   
      session=SessionNames(i);
      fname=regexprep(session, ' ', '_');
      
      filtOriData=OriData.(fname);
      % Process wavelet analysis for each session
      % Parallel computing is enabled for faster processing
      [OriScaleAve,wtOrder,Period,CoiRange]=generateSCaveWT2(filtOriData(:,2:end),ts,periodLimit,normflag,...
       scaleRange);
      % save to struct
       WA_data.(fname)=OriScaleAve;
      
      disp(strcat(session,'_','finished'))
end

%% Generate xCorr with sliding windows for all combinitions

windowsize=5.04;
wcoef=[0.5,0.45,0.4,0.35,0.3,0.25,0.2,0.17,0.15,0.12,0.1,0.05,0];
stepsize=5.04;
ts=0.04;
removeGravityFlag=false;
normflag=true;
windownormflag=false;
scaleopt="none";
%-------------------------------------------------------------------------
CCOriMax=struct;
% Example for all Sessions
for i=1:size(SessionNames,1)

    session=SessionNames(i);
    fname=regexprep(session, ' ', '_');

    filtOriData=OriData.(fname);
 

    [ccori,name1]=xcrossSlidingWin(filtOriData(:,2:end),ts,windowsize,stepsize,wcoef,...
        'removegravityflag',removeGravityFlag,'normflag',normflag,'windownormflag',windownormflag,'scaleopt',scaleopt);
    CCOriMax.(fname).(name1)=ccori;


    disp(strcat(session,'_','finished'))
end


%% Generate dtw with sliding windows for all combinitions
windowsize=5.04;
wcoef=[0.5,0.45,0.4,0.35,0.3,0.25,0.2,0.17,0.15,0.12,0.1,0.05,0];
stepsize=5.04;
ts=0.04;
removeGravityFlag=false;
normflag=false;
windownormflag=true;
%-------------------------------------------------------------------------------
DTWOri=struct;
% Example for all Sessions
for i=1:size(SessionNames,1)

    session=SessionNames(i);
    fname=regexprep(session, ' ', '_');

    filtOriData=OriData.(fname);

    [dtwori,name]=dtwSlidingWin(filtOriData(:,2:end),ts,windowsize,stepsize,wcoef,...
        'removegravityflag',removeGravityFlag,'normflag',normflag,'windownormflag',windownormflag);
    DTWOri.(fname).(name)=dtwori;

    disp(strcat(session,'_','finished'))
end
