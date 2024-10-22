%% MATLAB Script to Generate Simulated Acceleration Data in Case Study section
% This script generates two simulated acceleration signals,
% performs various similarity analysis, and visualizes the results.
% to priovide a tutorial of using different similarity analysis and
% evaluate the effiuciency of each algorithm

% Parameters
samplingRate = 25; % Hz
duration = 200; % seconds (2 minutes)
totalPoints = duration * samplingRate;
time = linspace(0, duration, totalPoints);
% Define types of movements from segments defined below
Types = [1,2,10,4,5,3,6,7,8,9];
% Types=[1,2,10,4,5,3,6,7,8,11]; % Alternative set of mov

% Function for Sine Wave (Synchronized Movement)
sineWave = @(t, freq, amp, phase) amp * sin(2 * pi * freq * t + phase);

% Function for Random Noise
randomNoise = @(len, scale) scale * randn(len, 1);

% Preallocate Arrays
dataPerson1 = zeros(totalPoints, 1);
dataPerson2 = zeros(totalPoints, 1);

% Define each segment (each segment is 10 seconds for more variety)
segmentLength=20;
for i = 1:(duration/segmentLength)
    idxStart = (i-1)*segmentLength*samplingRate + 1;
    idxEnd = i*segmentLength*samplingRate;
    n=Types(i);
    switch n
        case 1
        % Both movements are still
         dataPerson1(idxStart:idxEnd) = randomNoise(segmentLength * samplingRate, 0.05);
         dataPerson2(idxStart:idxEnd) = randomNoise(segmentLength * samplingRate, 0.05);
        case 2
        % One still and One with Large noise
        dataPerson1(idxStart:idxEnd) = randomNoise(segmentLength * samplingRate, 0.5);
        dataPerson2(idxStart:idxEnd) = randomNoise(segmentLength * samplingRate, 0.05);
        case 3
        % Large Noise with different amplitudes
        dataPerson1(idxStart:idxEnd) = randomNoise(segmentLength * samplingRate, 1);
        dataPerson2(idxStart:idxEnd) = randomNoise(segmentLength * samplingRate, 0.5);
        
        case 4
        % Synchronized 0.8x Sinewave Movement with short period (< 2s)
        dataPerson1(idxStart:idxEnd) = sineWave(time(idxStart:idxEnd), 3, 0.8, 0)'+randomNoise(segmentLength * samplingRate, 0.02);
        dataPerson2(idxStart:idxEnd) = sineWave(time(idxStart:idxEnd), 3, 0.8, 0)'+randomNoise(segmentLength * samplingRate, 0.02);

        case 5
         % Synchronized 1.2x Sinewave Movement with short period (< 2s)
        dataPerson1(idxStart:idxEnd) = sineWave(time(idxStart:idxEnd), 3, 1.2, 0)'+randomNoise(segmentLength * samplingRate, 0.02);
        dataPerson2(idxStart:idxEnd) = sineWave(time(idxStart:idxEnd), 3, 1.2, 0)'+randomNoise(segmentLength * samplingRate, 0.02);

        case 6
       
        % Synchronized 0.8x Sinewave Movement with long period (> 3s)
        dataPerson1(idxStart:idxEnd) = sineWave(time(idxStart:idxEnd), 0.3, 0.8, 0)'+randomNoise(segmentLength * samplingRate, 0.02);
        dataPerson2(idxStart:idxEnd) = sineWave(time(idxStart:idxEnd), 0.3, 0.8, 0)'+randomNoise(segmentLength * samplingRate, 0.02);
        case 7
        % Synchronized 1.2x Sinewave Movement with long period (> 3s)
        dataPerson1(idxStart:idxEnd) = sineWave(time(idxStart:idxEnd), 0.3, 1.2, 0)'+randomNoise(segmentLength * samplingRate, 0.02);
        dataPerson2(idxStart:idxEnd) = sineWave(time(idxStart:idxEnd), 0.3, 1.2, 0)'+randomNoise(segmentLength * samplingRate, 0.02);
        
        case 8
        % Synchronized Sinewave with one with shifted phase
        dataPerson1(idxStart:idxEnd) = sineWave(time(idxStart:idxEnd), 0.4, 1, 0)'+randomNoise(segmentLength * samplingRate, 0.02);
        dataPerson2(idxStart:idxEnd) = sineWave(time(idxStart:idxEnd), 0.4, 1, 0.25*pi)'+randomNoise(segmentLength * samplingRate, 0.02); % phase shift
   
        case 9
        % Synchronized Sinewave with one with shifted phase
        dataPerson1(idxStart:idxEnd) = sineWave(time(idxStart:idxEnd), 0.4, 1, 0)'+randomNoise(segmentLength * samplingRate, 0.02);
        dataPerson2(idxStart:idxEnd) = sineWave(time(idxStart:idxEnd), 0.4, 1, 0.5*pi)'+randomNoise(segmentLength * samplingRate, 0.02); % phase shift

        case 10
         % One still and One with Sinewave Movement
        dataPerson1(idxStart:idxEnd) = randomNoise(segmentLength * samplingRate, 0.05);
        dataPerson2(idxStart:idxEnd) = sineWave(time(idxStart:idxEnd), 0.3, 0.5, 0);
        case 11
         % Synchronized 1.2x Sinewave Movement with long period (> 3s)
        dataPerson1(idxStart:idxEnd) = sineWave(time(idxStart:idxEnd), 0.3, 1.2, 0)';
        dataPerson2(idxStart:idxEnd) = sineWave(time(idxStart:idxEnd), 0.3, 1.2, 0)';
    end

end

% Plot the Data
figure
plot(time, dataPerson1);
hold on;
plot(time, dataPerson2);
xlabel('Time (s)');
ylabel('Acceleration');
title('Simulated Acceleration Data with Varied Synchronization');
legend('Person 1', 'Person 2');

%% Prepare simulated data
t=time';
simulatedData=[t,dataPerson1,dataPerson2];

%% Wavelet analysis
ts=0.04;
periodLimit=[0.2,5];
scaleRange=[[0.2,2];[2,10]];
normflag=false;

[OriScaleAve,wtOrder,Period,CoiRange]=generateSCaveWT2(simulatedData(:,2:3),ts,periodLimit,normflag,scaleRange);
 Alg=OriScaleAve;
%% xcorrelation 

windowsize=5.04;
wcoef=0.3;
stepsize=2.52;

scaleopt="none";
[ccori,name1]=xcrossSlidingWin(simulatedData(:,2:3),ts,windowsize,stepsize,wcoef...
    ,'removegravityflag', false, 'normflag', true, 'windownormflag', false, ...
      'scaleopt', "none");
Alg.(strcat('CC_',name1))=ccori;
%% ED
windowsize=5.04;
wcoef=0;
stepsize=2.52;

[dtwori,name1]=dtwSlidingWin(simulatedData(:,2:3),ts,windowsize,stepsize,wcoef,...
    'removegravityflag', false, 'normflag', false, 'windownormflag', true);
Alg.(strcat('ED_',name1))=dtwori;
%% Dynamic time warping 
windowsize=5.04;
wcoef=0.3;
stepsize=2.52;

[dtwori,name1]=dtwSlidingWin(simulatedData(:,2:3),ts,windowsize,stepsize,wcoef,...
    'removegravityflag', false, 'normflag', false, 'windownormflag', true);
Alg.(strcat('DTW_',name1))=dtwori;


%% Plot results from each analysis

LegendName=["CC","ED","DTW","XWT(0.2-2s)","WCT(0.2-2s)","XWT lowf(2-5s)","WCT(2-5s)"];
lineW=4;
FN=fieldnames(Alg);
FN=[FN(5);FN(6);FN(7);FN(1);FN(2);FN(3);FN(4)];
noplot=length(FN)+2;
figure
ax=subplot(noplot,1,[1,2]);
plot(t,simulatedData(:,2),'LineWidth',2,'Color','#6c9bcf')
hold on
plot(t,simulatedData(:,3),'LineWidth',2,'Color','#de8f5f')
set(gca,"FontSize",20)
xticks([]);
xlim([0,t(end)]);
legend(["Data 1","Data 2" ])
grid minor 
box off
Colors=["#7c9d96","#ffd28f","#ffd28f","#9a4444","#3876bf","#9a4444","#3876bf"];
for i=1:length(FN)
    ax1=subplot(noplot,1,i+2);
    plot(t,Alg.(FN{i,1}){1,1},'LineWidth',lineW,'Color',Colors(i))
    % tname=split(FN{i,1},'_');
    % title(tname{1,1})
    ax=[ax,ax1];
    set(gca,"FontSize",20)
    legend(LegendName(i))
    grid minor 
    box off
    xlim([0,t(end)]);
    if i+2~=noplot
        xticks([]);
        % yticks([]);
    end
end
ylabel('Similarity')
xlabel('Time/s')
linkaxes(ax,'x')