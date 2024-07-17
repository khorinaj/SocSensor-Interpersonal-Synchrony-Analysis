%% Demo of the cross wavelet and wavelet coherence toolbox 
% This example illustrates how simple it is to do
% continuous wavelet transform (CWT), Cross wavelet transform (XWT)
% and Wavelet Coherence (WTC) plots of your own data.
%
% The time series we will be analyzing are the winter
% Arctic Oscillation index (AO) and
% the maximum sea ice extent in the Baltic (BMI).
%


%% Load the data
% First we load the two time series into the matrices d1 and d2.

seriesname={'AO' 'BMI'};
d1=load('faq\jao.txt');
d2=load('faq\jbaltic.txt');

%% Change the pdf.
% The time series of Baltic Sea ice extent is highly bi-modal and we
% therefore transform the timeseries into a series of percentiles. The
% transformed series probably reacts 'more linearly' to climate.


d2(:,2)=boxpdf(d2(:,2));


%% Continuous wavelet transform (CWT)
% The CWT expands the time series into time
% frequency space.

figure('color',[1 1 1])
tlim=[min(d1(1,1),d2(1,1)) max(d1(end,1),d2(end,1))];
subplot(2,1,1);
wt(d1);
title(seriesname{1});
set(gca,'xlim',tlim);
subplot(2,1,2)
wt(d2)
title(seriesname{2})
set(gca,'xlim',tlim)


%% Cross wavelet transform (XWT)
% The XWT finds regions in time frequency space where
% the time series show high common power.
addpath('C:\Users\khori\OneDrive - University College London\Phd\Bloomsbury_data_analysis\wavelet-coherence-master\wavelet-coherence-master')
figure('color',[1 1 1])
xwt(d1,d2)
title(['XWT: ' seriesname{1} '-' seriesname{2} ] )
[wcs2,period2,scale2,coi2,~]=xwt(d1,d2);
%% Wavelet coherence (WTC)
% The WTC finds regions in time frequency space where the two
% time series co-vary (but does not necessarily have high power).

addpath('C:\Users\khori\OneDrive - University College London\Phd\Bloomsbury_data_analysis\wavelet-coherence-master\wavelet-coherence-master')
figure('color',[1 1 1])
wtc(d1,d2)
%title(['WTC: ' seriesname{1} '-' seriesname{2} ] )
title(['WTC: ' A0 '-' A1 ] )
[wcoh2,period22,scale22,coi22,~]=wtc(d1,d2);
%% phase scambled
PSd1 = phase_scramble(d1(:,2));
PSd2 = phase_scramble(d2(:,2));

PSd1=[d1(:,1),PSd1];
PSd2=[d2(:,1),PSd2];
%% baseline
xwt1=xwt(d1,d2);
wct1=wtc(d1,d2);

xwt2=xwt(PSd1,PSd2);
wct2=wtc(PSd1,PSd2);
xwtReal=xwt1-xwt2;
wctReal=wtc_baseline(xwt2,d1,d2);
xwtori=mean(mean(abs(xwt1)))
xwtreal=mean(mean(abs(xwt1-xwt2)))
wctori=mean(mean(wct1))
wctReal=mean(mean(wctReal))
%%
[a,b]=xwtwct_baseline(xwt1,PSd1,PSd2);
xwtreal=mean(mean(abs(a)))
wctReal=mean(mean(b))
%% Calculating Average
%coi_range=29:119;
%coi_range=11004:98351;

avewcs1=mean(abs(wcs2(6:end,coi_range)));
avewcs=abs(mean(wcs2(6:end,coi_range)));
avecoh=mean(wcoh2(6:end,coi_range));
figure
plot(1:length(coi_range),rescale(avewcs1,0,1),1:length(coi_range),rescale(avewcs,0,1),1:length(coi_range),avecoh)
legend(["wcs_","wcs_p","wcoh"])
legend(["wcs_","wcs_p","wcoh"])
title("Paper method")
%% Compare with Matlab function
figure
wcoherence(d1(:,2),d2(132:(end-2),2),years(1));
[wcoh1,wcs1,period1,coi1]=wcoherence(d1(:,2),d2(132:(end-2),2),years(1));
%%

avewcs1=mean(abs(wcs1(:,coi_range)));
avewcs=abs(mean(wcs1(:,coi_range)));
avecoh=mean(wcoh1(:,coi_range));
figure
plot(1:length(coi_range),abs(avewcs1),1:length(coi_range),abs(avewcs),1:length(coi_range),avecoh)
legend(["wcs","wcs_p","wcoh"])
title("Matlab Method")
%% Compare with Jamie's method
addpath('C:\Users\khori\OneDrive - University College London\Phd\Bloomsbury_data_analysis\Matlab')
tic
[wcoh3,wcs3,period3,scale3,coi3,~,waveX,waveY]=jw_wtc(d1,d2);
toc
%jw_wtc(d1,d2,'MakeFigure',1);
%%
Wxy=calculate_cross_from_wavelets(waveX,waveY);
Rsq = calculate_coherence_from_wavelets( waveX, waveY, wcs3, scale3, period3,1);
%%

avewcs1=mean(abs(wcs3(6:end,coi_range)));
avewcs=abs(mean(wcs3(6:end,coi_range)));
avecoh=mean(wcoh3(6:end,coi_range));
figure
plot(1:length(coi_range),abs(avewcs1),1:length(coi_range),abs(avewcs),1:length(coi_range),avecoh)
legend(["wcs","wcs_p","wcoh"])
title('Jamie edited method')
%% --------------- MY data -----------------------------------
%% --------------- MY data -----------------------------------
%% --------------- MY data -----------------------------------
%% other option of data
data=Sync_data_Act2;
x=data(1:10000,2);
y=data(1:10000,3);
t1=0:0.04:((length(x)-1)*0.04);
d1=[t1',x];
d2=[t1',y];
%% Continuous wavelet transform (CWT)
% The CWT expands the time series into time
% frequency space.

figure('color',[1 1 1])
tlim=[min(d1(1,1),d2(1,1)) max(d1(end,1),d2(end,1))];
subplot(2,1,1);
wt(d1);
%title(seriesname{1});
set(gca,'xlim',tlim);
subplot(2,1,2)
wt(d2)
%title(seriesname{2})
set(gca,'xlim',tlim)
%% Cross wavelet transform (XWT)
% The XWT finds regions in time frequency space where
% the time series show high common power.
addpath('C:\Users\khori\OneDrive - University College London\Phd\Bloomsbury_data_analysis\wavelet-coherence-master\wavelet-coherence-master')
figure('color',[1 1 1])
xwt(d1,d2)
%title(['XWT: ' seriesname{1} '-' seriesname{2} ] )
% tic
 [wcs2,period2,scale2,coi2,~]=xwt(d1,d2,'S0',0.1,'MaxScale',200);
% toc
% Elapsed time is 2.928808 seconds.
%%
sc_range=5:133;
%sc_range=1:57;
coi_range=time_range;
avewcs1=mean(abs(wcs3(sc_range,coi_range)));
avewcs=abs(mean(wcs3(sc_range,coi_range)));
%avecoh=mean(wcoh3(sc_range,coi_range));
figure
plot(1:length(coi_range),abs(avewcs1),1:length(coi_range),abs(avewcs))
legend(["wcs","wcs_p"])
title('Paper method')
%% Wavelet coherence (WTC)
% The WTC finds regions in time frequency space where the two
% time series co-vary (but does not necessarily have high power).

addpath('C:\Users\khori\OneDrive - University College London\Phd\Bloomsbury_data_analysis\wavelet-coherence-master\wavelet-coherence-master')
figure('color',[1 1 1])
wtc(d1,d2)
%title(['WTC: ' seriesname{1} '-' seriesname{2} ] )
%title(['WTC: ' A0 '-' A1 ] )
[wcoh2,period22,scale22,coi22,~]=wtc(d1,d2);

%% Calculating Average
%coi_range=29:119;
coi_range=11004:98351;
avewcs1=mean(abs(wcs2(6:end,coi_range)));
avewcs=abs(mean(wcs2(6:end,coi_range)));
avecoh=mean(wcoh2(6:end,coi_range));
figure
plot(1:length(coi_range),rescale(avewcs1,0,1),1:length(coi_range),rescale(avewcs,0,1),1:length(coi_range),avecoh)
legend(["wcs_","wcs_p","wcoh"])
legend(["wcs_","wcs_p","wcoh"])
title("Paper method")
%% PLOT ORI DATA
figure
fig=gcf;
plot(t1,y,'r')
set(gca,'FontSize',14)
xlabel('time (s)')
ylabel('Acceleration (g)')
%% plot time ave
timeave=mean(wcoh2,2);
figure
fig=gcf;
plot(timeave,log2(period22))

set(gca, 'YDir','reverse')
set(gca,'FontSize',14)
%ylim([0,128])
xlabel('Time-averaged power')
ylabel('Period (s)')
%% Compare with Matlab function
figure
wcoherence(x,y,seconds(0.04));
tic
[wcoh1,wcs1,period1,coi1]=wcoherence(x,y,seconds(0.04));
toc
% Elapsed time is 7.175024 seconds.
%%
windowSize=1000;
b = (1/windowSize)*ones(1,windowSize);
a = 1;
sc_range=1:131;
avewcs1=mean(abs(wcs1(sc_range,coi_range)));
avewcs=abs(mean(wcs1(sc_range,coi_range)));
avecoh=mean(wcoh1(sc_range,coi_range));
figure
plot(1:length(coi_range),filter(b,a,avewcs1),1:length(coi_range),filter(b,a,avewcs),1:length(coi_range),filter(b,a,avecoh))
legend(["wcs","wcs_p","wcoh"])
title("Matlab Method")
%% Compare with Jamie's method
addpath('C:\Users\khori\OneDrive - University College London\Phd\Bloomsbury_data_analysis\Matlab')
tic
[wcoh3,wcs3,period3,scale3,coi3,~,waveX,waveY]=jw_wtc(d1,d2);
toc
% Elapsed time is 243.504439 seconds.
%jw_wtc(d1,d2,'MakeFigure',1);
%%
waveX = cwt(x,'amor',seconds(0.04));
waveY = cwt(x,'amor',seconds(0.04));
Wxy=calculate_cross_from_wavelets(waveX,waveY);
Rsq = calculate_coherence_from_wavelets( waveX, waveY, wcs3, scale3, period3,1);

%%
sc_range=1:118;
dataplot=Wxy;
avewcs1=mean(abs(dataplot(sc_range,coi_range)));
avewcs=abs(mean(dataplot(sc_range,coi_range)));
figure
plot(1:length(coi_range),abs(avewcs1),1:length(coi_range),abs(avewcs))
legend(["wcs","wcs_p"])
title('Jamie edited method')
%%
%sc_range=5:136;
dataplot=Wxy;
dataplot2=Rsq;
avewcs1=mean(abs(dataplot(sc_range,coi_range)));
avewcs=abs(mean(dataplot(sc_range,coi_range)));
avecoh=mean(dataplot2(sc_range,coi_range));
figure
plot(1:length(coi_range),abs(avewcs1),1:length(coi_range),abs(avewcs),1:length(coi_range),filter(b,a,avecoh))
legend(["wcs","wcs_p","wcoh"])
title('Jamie edited method')
%%
function Rsq = calculate_coherence_from_wavelets( waveX, waveY, Wxy, scale, period, dt )
    Dj = 1/12;
    X = waveX;
    Y = waveY;
    [nPeriods, n] = size(X);
    
    sinv=1./(scale');

    sX=smoothwavelet( sinv(:,ones(1,n)).*(abs(X).^2), dt, period, Dj, scale );
    sY=smoothwavelet( sinv(:,ones(1,n)).*(abs(Y).^2), dt, period, Dj, scale );

    % ----------------------- Wavelet coherence ---------------------------------
    sWxy=smoothwavelet( sinv(:,ones(1,n)).*Wxy, dt, period, Dj, scale );
    Rsq=abs(sWxy).^2./(sX.*sY);
end
function Wxy = calculate_cross_from_wavelets( waveX, waveY )
    % -------- Cross wavelet -------
    Wxy=waveX.*conj(waveY); 
end