
%% Setup
addpath DPA
addpath DES
addpath matlab_support_functions

%% Parameters
whichSBox = 1; % 1-8
whichSBoxOutputBit = 2;% 1-4;
whichExperiment = '23';
keyString = 'KeyB' %KeyA KeyB KeyAInv KeyBInv
 
%% Fetch Decrypt Text (partialDecryptText)
%partialDecryptTextDir = '/mnt/raid2/share/DPAData/PartialDecryptText/'; !!!!!
partialDecryptTextDir = '/mnt/raid2/share/DPAData/'; 
partialDecryptTextFilename = ['partialDecryptText_', keyString,'_SBOX',num2str(whichSBox),'.mat'];
partialDecryptTextPath = [partialDecryptTextDir, partialDecryptTextFilename];
load(partialDecryptTextPath,'partialDecryptText')

%partialDecryptText = logical(S.partialDecryptText);
fprintf('fetched text\n')
%% Fetch Experiment Trace Data 
experimentDir = '/mnt/raid2/share/DPAData/Experiments/';
experimentFilename = ['Experiment_',num2str(whichExperiment),'.mat'];
experimentPath = [experimentDir, experimentFilename];
load(experimentPath,'actualKeyParityCorrect','itrStart','itrEnd','traceDataAllCh')

fprintf('fetched experimental data\n')
%% Compute Which Bits in the 1-round decrypt data we should be looking at
attackBitNumber = DPA_FindAttackBitIndexInPartialDecipher(whichSBox,whichSBoxOutputBit)


%% Compute DPA traces
%parameters:
attackItrStart = itrStart;
%attackItrEnd = itrEnd;
%attackItrEnd = 1000000;
attackItrStart = 100001; 
attackItrEnd = 1e6;
attackItrStart = 1; 
attackItrEnd = 50000;
itrStart = attackItrStart
itrEnd = attackItrEnd
guessMax = 64; %typically leave as 64 to check all 64 guesses, unless you want shorter run-time for code testing
numthreads = 16;


%toc

if rem(guessMax,numthreads)>0
    error 'guessMax/numthreads should be an integer'
end
tic
%uncomment C or MATLAB below
%dpaTrace_CGT = DPATracerWrapper('C',traceDataAllCh, attackItrStart,attackItrEnd,partialDecryptText,attackBitNumber,guessMax,numthreads);
dpaTrace_CGT = DPATracerWrapper('MATLAB',traceDataAllCh, itrStart,itrEnd,partialEncryptText,attackBitNumber,guessMax,numthreads);
toc % 35.314715 seconds
%dpaTrace_CGT = DPATracerW(traceDataAllCh, itrStart,itrEnd,partialDecryptText,attackBitNumber,guessMax,numthreads);


%% Plot raw data
%tt=1:length(trace0MeanCh1{1});
tStep = 214200e-9/21420;%assumes 500 points on scope and 400ns total
tt=[0:(length(traceDataAllCh(1,1,:))-1)]*tStep; 
figure;
plotTraceRange = [1:50000];
myfun = inline('x');  xx = tt; %plot all points
%myfun = inline('x(225+[-24:24])');  xx = 225+[-24:24]; %plot subregion where attack is expexted 
%myfun = inline('(abs(fft(single(x(225+[-24:24])))))');  xx = 0:48;
%myfun = inline('(phase(fft(single(x(225+[-24:24])))))');  xx = 0:48;
for traceItr=plotTraceRange
    labelText=sprintf('%d',traceItr);
    %traceItr
    %plot(traceDataCh1)
    %plot(tt,traceDataAllCh{guessItr},'DisplayName',labelText); hold all;title('ch1');
    subploth(1)=subplot(2,2,1);
    hPlot(1,traceItr)=plot(xx,myfun(squeeze(traceDataAllCh(1,traceItr,:))'),'DisplayName',labelText); hold all;title('ch1');
%     subploth(2)=subplot(2,2,2);
%     hPlot(2,traceItr)=plot(xx,myfun(squeeze(traceDataAllCh(2,traceItr,:))'),'DisplayName',labelText); hold all;title('ch2');
    subploth(3)=subplot(2,2,3);
    hPlot(2,traceItr)=plot(xx,myfun(squeeze(traceDataAllCh(2,traceItr,:))'),'DisplayName',labelText); hold all;title('ch3');
%     subploth(4)=subplot(2,2,4);
%     hPlot(4,traceItr)=plot(xx,myfun(squeeze(traceDataAllCh(4,traceItr,:))'),'DisplayName',labelText); hold all;title('ch4');
    %setgridcolor([.7 .7 .7]);
    %vline(0,'k');
    %vline(-100e-9,'k');
    %legend('show')
end



%% Plot dpa traces with correct-key trace overlay
%% | plot
%tt=1:length(trace0MeanCh1{1});
tStep = 214200e-9/21420;%assumes 500 points on scope and 400ns total
tt=[0:(length(dpaTrace_CGT(1,1,:))-1)]*tStep; 
myfun = inline('x');  xx = tt;
figure;
for guessItr=1:64
    labelText=sprintf('%d',guessItr);
    guessItr
    %plot(traceDataCh1)
    %plot(tt,traceDataAllCh{guessItr},'DisplayName',labelText); hold all;title('ch1');
    subploth(1)=subplot(2,2,1);
    hPlot(1,guessItr)=plot(tt,squeeze(dpaTrace_CGT(1,guessItr,:)),'DisplayName',labelText, 'LineWidth',1); hold on;title('ch1');
    %pause(1);
    %subploth(2)=subplot(2,2,2);
    %hPlot(2,guessItr)=plot(tt,squeeze(dpaTrace_CGT(2,guessItr,:))','DisplayName',labelText); hold all;title('ch2');
    subploth(3)=subplot(2,2,3);
    hPlot(3,guessItr)=plot(tt,squeeze(dpaTrace_CGT(2,guessItr,:))','DisplayName',labelText, 'LineWidth', 1); hold on;title('ch3');
%     subploth(4)=subplot(2,2,4);
%     hPlot(4,guessItr)=plot(tt,squeeze(dpaTrace_CGT(4,guessItr,:))','DisplayName',labelText); hold all;title('ch4');
    %setgridcolor([.7 .7 .7]);
    %vline(0,'k');
    %vline(-100e-9,'k');4
    %legend('show')
end


% | Identify correct key iteration
allguesses = DPA_Gen64KeyGuessesForSBox(whichSBox,1);
which6IndexesInKey64 = DPA_FindBitIndexesOfInterestInKey64(whichSBox, 1);

correctGuessItr = NaN;
for guessItr = 1:64,
    if sum(allguesses(guessItr,which6IndexesInKey64) == actualKeyParityCorrect(which6IndexesInKey64))==6
       correctGuessItr = guessItr
    end
end
if isnan(correctGuessItr)
    error 'correct key not found'
end
% | highlight the correct key
set(hPlot(1,correctGuessItr),'LineWidth',3,'DisplayName',labelText,'Color',[1 .5 0]);
%set(hPlot(2,correctGuessItr),'LineWidth',3,'DisplayName',labelText,'Color',[1 .5 0]);
set(hPlot(3,correctGuessItr),'LineWidth',3,'DisplayName',labelText,'Color',[1 .5 0]);
%set(hPlot(4,correctGuessItr),'LineWidth',3,'DisplayName',labelText,'Color',[1 .5 0]);

%% | mark attack window
%Parameters:
%attackStartIndex = 201; attackEndIndex = 249;
attackStartIndex = 201-50; attackEndIndex = 249-50;


subplot(2,2,1);
vline(tt([attackStartIndex,attackEndIndex]),'r-')
subplot(2,2,2);
vline(tt([attackStartIndex,attackEndIndex]),'r-')
subplot(2,2,3);
vline(tt([attackStartIndex,attackEndIndex]),'r-')
subplot(2,2,4);
vline(tt([attackStartIndex,attackEndIndex]),'r-')

%linkaxes(temph)
%plot(tt,dpaTraceCh1{guessItr},'DisplayName',labelText); hold all;title('ch1');
%plot correct key in orangetemplateAllCh1



%% Plot function of dpa traces with correct-key trace overlay

%myfun = inline('(abs(fft(x(250+[-50:50]))))')
%myfun = inline('(abs((x([attackStartIndex:attackEndIndex]))))');  %xx = linspace(0,(1/tStep),49);
%myfun = @(x) abs((x(attackStartIndex:attackEndIndex))); xx = attackStartIndex:attackEndIndex;

%% Simple Plot
 
 myfunc = @(x) abs(fft(x(attackStartIndex:attackEndIndex))); 
 plotfunc1 = @(x1,x2,x3,x4) myfunc(x1)';
 plotfunc2 = @(x1,x2,x3,x4) myfunc(x2)';
 plotfunc3 = @(x1,x2,x3,x4) myfunc(x4)';
 plotfunc4 = @(x1,x2,x3,x4) myfunc(x3)';
 xx = 0:(attackEndIndex-attackStartIndex); axisTitles = {'ch1','ch2','ch4','ch3'};

%% Filtered Data Plot
 
 myfunc = @(x) (fft(x(attackStartIndex:attackEndIndex))); 
 plotfunc1 = @(x1,x2,x3,x4) abs(myfunc(x1)'.*W_1k1to1M(1,:));
 plotfunc2 = @(x1,x2,x3,x4) abs(myfunc(x2)'.*W_1k1to1M(2,:));
 plotfunc3 = @(x1,x2,x3,x4) abs(myfunc(x4)'.*W_1k1to1M(4,:));
 plotfunc4 = @(x1,x2,x3,x4) abs(myfunc(x3)'.*W_1k1to1M(3,:));
 xx = 0:(attackEndIndex-attackStartIndex); axisTitles = {'ch1','ch2','ch4','ch3'};

%% Simple Plot Wiener Filter
 
 myfunc = @(x) abs(fft(x(attackStartIndex:attackEndIndex))); 
 plotfunc1 = @(x1,x2,x3,x4) abs(W_1k1to1M(1,:));
 plotfunc2 = @(x1,x2,x3,x4) abs(W_1k1to1M(2,:));
 plotfunc3 = @(x1,x2,x3,x4) abs(W_1k1to1M(4,:));
 plotfunc4 = @(x1,x2,x3,x4) abs(W_1k1to1M(3,:));
 xx = 0:(attackEndIndex-attackStartIndex); axisTitles = {'ch1','ch2','ch4','ch3'};

 
 
 
%% Template Match To Correct
%{
 %%steal info from correct trace
  
  figure;plot(abs(metric)); vline(correctGuessItr);
  
  abs(metric(correctGuessItr)) / std(abs(metric))

 templateCh1 = squeeze(dpaTrace_CGT(1,correctGuessItr,:));
 templateCh2 = squeeze(dpaTrace_CGT(2,correctGuessItr,:));
 templateCh3 = squeeze(dpaTrace_CGT(3,correctGuessItr,:));
 templateCh4 = squeeze(dpaTrace_CGT(4,correctGuessItr,:));
 
 myfunc = @(x) abs(fft(x(attackStartIndex:attackEndIndex))); 
 plotfunc1 = @(x1,x2,x3,x4) myfunc(x1)
 plotfunc2 = @(x1,x2,x3,x4) myfunc(x2)
 plotfunc3 = @(x1,x2,x3,x4) myfunc(x3)
 plotfunc4 = @(x1,x2,x3,x4) myfunc(x4)
 xx = attackStartIndex:attackEndIndex; axisTitles = {'c1','ch2','ch2','ch4'};
%}
 %%
 

%myfun = inline('(abs(fft(x(200+[-50:50]))))')
%myfun = inline('(abs(fft(x(230+[-20:20]))))')


tt=1:length(dpaTrace_CGT(1,guessItr,:));
figure;
for guessItr = 1:64,
    labelText=sprintf('%d',guessItr);
    subploth(1)=subplot(2,2,1);
    hPlot(1,guessItr) = plot(xx,plotfunc1(squeeze(dpaTrace_CGT(1,guessItr,:)),squeeze(dpaTrace_CGT(2,guessItr,:)),squeeze(dpaTrace_CGT(3,guessItr,:)),squeeze(dpaTrace_CGT(4,guessItr,:))),'DisplayName',labelText); hold all;title(axisTitles{1});
    subploth(1)=subplot(2,2,2);
    hPlot(2,guessItr) = plot(xx,plotfunc2(squeeze(dpaTrace_CGT(1,guessItr,:)),squeeze(dpaTrace_CGT(2,guessItr,:)),squeeze(dpaTrace_CGT(3,guessItr,:)),squeeze(dpaTrace_CGT(4,guessItr,:))),'DisplayName',labelText); hold all;title(axisTitles{2});
    subploth(1)=subplot(2,2,3);
    hPlot(3,guessItr) = plot(xx,plotfunc3(squeeze(dpaTrace_CGT(1,guessItr,:)),squeeze(dpaTrace_CGT(2,guessItr,:)),squeeze(dpaTrace_CGT(3,guessItr,:)),squeeze(dpaTrace_CGT(4,guessItr,:))),'DisplayName',labelText); hold all;title(axisTitles{3});
    subploth(1)=subplot(2,2,4);
    hPlot(4,guessItr) = plot(xx,plotfunc4(squeeze(dpaTrace_CGT(1,guessItr,:)),squeeze(dpaTrace_CGT(2,guessItr,:)),squeeze(dpaTrace_CGT(3,guessItr,:)),squeeze(dpaTrace_CGT(4,guessItr,:))),'DisplayName',labelText); hold all;title(axisTitles{4});
    %setgridcolor([.7 .7 .7]);
    %vline(0,'k');
    %vline(-100e-9,'k');
    %legend('show')
end
%linkaxes(temph)

%%% modify plot line of correct key to highlight it
%guessItr=52;
%guessItr=13;
%guessItr=17;
%guessItr=48;

set(hPlot(1,correctGuessItr),'LineWidth',3,'DisplayName',labelText,'Color',[1 .5 0]);
set(hPlot(2,correctGuessItr),'LineWidth',3,'DisplayName',labelText,'Color',[1 .5 0]);
set(hPlot(3,correctGuessItr),'LineWidth',3,'DisplayName',labelText,'Color',[1 .5 0]);
set(hPlot(4,correctGuessItr),'LineWidth',3,'DisplayName',labelText,'Color',[1 .5 0]);

%All64KeyGuesses(guessItr,:) == actualKeyParityCorrect


%% Do metrics

myfun = inline('var(x(225+[-24:24]))');  xx = 0:48;%xx = linspace(0,(1/tStep),49);

for guessItr = 1:64,
    metric(1,guessItr) = myfun(squeeze( dpaTrace_CGT(1,guessItr,:)));
    metric(2,guessItr) = myfun(squeeze( dpaTrace_CGT(2,guessItr,:)));
    metric(3,guessItr) = myfun(squeeze( dpaTrace_CGT(3,guessItr,:)));
    metric(4,guessItr) = myfun(squeeze( dpaTrace_CGT(4,guessItr,:)));
end

for row = 1:4
    metric(row,:) =     metric(row,:) / sum(metric(row,:));
end

figure;plot(metric')
%figure;hist(metric',100)
vline(correctGuessItr,'m--');legend('1','2','3','4')

%% Some more-sofisticated metrics
%% create wiener filter
templateAllCh_1k1to1M = squeeze(dpaTrace_CGT(:,correctGuessItr,attackStartIndex:attackEndIndex));
AllCh_1k1to1M         = squeeze(dpaTrace_CGT(:,              :,attackStartIndex:attackEndIndex));

Sxx = abs(fft(templateAllCh_1k1to1M(:,:,:)')').^2; %use fft as spectral est.

guessFFTSum2 = zeros(size(Sxx));
for guessItr = 1:64,
   guessFFT2 = abs(((fft(squeeze(AllCh_1k1to1M(:,guessItr,:)))')')).^2;%%**!!!When I forgot ABS here result was better !??!
   guessFFTSum2 = guessFFTSum2 + guessFFT2;
end

W_1k1to1M =  Sxx./guessFFTSum2;

%%


%steal info from correct trace
 %templateAllCh1M = squeeze(dpaTrace_CGT(:,correctGuessItr,:));
 %templateAllCh_1k1to1M = squeeze(dpaTrace_CGT(:,correctGuessItr,:));
 
  d=fdesign.lowpass('Fp,Fst,Ap,Ast',1/500,2/500,1,20);
  Hd1=design(d,'equiripple'); %FIR equiripple, butter design
  figure;plot(abs(fft(filter(Hlp.Numerator,1,1:500==1))))

  
  templateAllCh_filtered = filter(Hlp.Numerator,1,double(templateAllCh_1k1to1M(:,attackStartIndex:attackEndIndex)));
  %templateAllCh = filter(1,1,double(templateAllCh1M(:,attackStartIndex:attackEndIndex)));
 
%  templateAllCh_filtered = zeros(4,49);
%  templateAllCh_filtered = templateAllCh_1k1to1M(:,attackStartIndex:attackEndIndex);
%  templateAllCh_filtered
 
   templateAllCh_filtered_fft = fft(templateAllCh_1k1to1M(:,attackStartIndex:attackEndIndex)')';
   templateAllCh_filtered_fft(:,3:49) = zeros(4,49-3+1);


 
  clear metric
  for guessItr = 1:64,
    guessData = squeeze((dpaTrace_CGT(:,guessItr,attackStartIndex:attackEndIndex)));
   % guessData = filter(Hlp.Numerator,1, squeeze((dpaTrace_CGT(:,guessItr,attackStartIndex:attackEndIndex))));
    %metric(guessItr) = kronprod((templateAllCh_1k1to1M(:,attackStartIndex:attackEndIndex)),guessData);
    %metric(guessItr) = kronprod((templateAllCh_1k1to1M(:,attackStartIndex:attackEndIndex)),guessData);
    %metric(guessItr) = mean(mean(semicolon(squeeze((dpaTrace_CGT(1:4,guessItr,attackStartIndex:attackEndIndex))))));
    metric(guessItr) = mean(mean(fft(squeeze(dpaTrace_CGT(1:4,guessItr,attackStartIndex:attackEndIndex))')' .* W_1k1to1M));
    
    
%    metric(guessItr) = kronprod(templateAllCh_filtered_fft,fft(guessData')');

 %   guessDataFFT= fft(guessData')';
 %   metric(guessItr) = mean(mean(guessDataFFT(4,1:3)));
    
  end

  
  
  
  figure;plot(abs(metric)); vline(correctGuessItr);
  
  abs(metric(correctGuessItr)) / std(abs(metric))

    
%%
 
 myfunc = @(x) abs(fft(x(attackStartIndex:attackEndIndex))); 
 plotfunc1 = @(x1,x2,x3,x4) myfunc(x1)
 plotfunc2 = @(x1,x2,x3,x4) myfunc(x2)
 plotfunc3 = @(x1,x2,x3,x4) myfunc(x3)
 plotfunc4 = @(x1,x2,x3,x4) myfunc(x4)
 xx = attackStartIndex:attackEndIndex; axisTitles = {'c1','ch2','ch2','ch4'};

%% PCA Metric
%first use training data
X1 = (squeeze(dpaTrace_CGT_1_1M(1,:,attackStartIndex:attackEndIndex)))'; %data in columns of X
X2 = (squeeze(dpaTrace_CGT_1_1M(2,:,attackStartIndex:attackEndIndex)))';
X3 = (squeeze(dpaTrace_CGT_1_1M(3,:,attackStartIndex:attackEndIndex)))';
X4 = (squeeze(dpaTrace_CGT_1_1M(4,:,attackStartIndex:attackEndIndex)))';


[V1,D1] = eig(X1*X1'); lambda_sq1 = diag(D1);
[V2,D2] = eig(X2*X2'); lambda_sq2 = diag(D2);
[V3,D3] = eig(X3*X3'); lambda_sq3 = diag(D3);
[V4,D4] = eig(X4*X4'); lambda_sq4 = diag(D4);


%use experimental data
X1 = (squeeze(dpaTrace_CGT_1_100k(1,:,attackStartIndex:attackEndIndex)))'; %data in columns of X
X2 = (squeeze(dpaTrace_CGT_1_100k(2,:,attackStartIndex:attackEndIndex)))';
X3 = (squeeze(dpaTrace_CGT_1_100k(3,:,attackStartIndex:attackEndIndex)))';
X4 = (squeeze(dpaTrace_CGT_1_100k(4,:,attackStartIndex:attackEndIndex)))';

metric1  = (V1' * X1)' * lambda_sq1;
metric2  = (V2' * X2)' * lambda_sq2;
metric3  = (V3' * X3)' * lambda_sq3;
metric4  = (V4' * X4)' * lambda_sq4;

faha;
plot(metric1);hold all;




clear metric
for guessItr = 1:64,
  guessData = squeeze((dpaTrace_CGT(:,guessItr,attackStartIndex:attackEndIndex)));
  % guessData = filter(Hlp.Numerator,1, squeeze((dpaTrace_CGT(:,guessItr,attackStartIndex:attackEndIndex))));
  metric(guessItr) = kronprod((templateAllCh),guessData);
  %metric(guessItr) = mean(semicolon(squeeze((dpaTrace_CGT(4,guessItr,attackStartIndex:attackEndIndex)))));
end

  figure;plot(metric); metric(correctGuessItr)/std(metric)
  vline(correctGuessItr);

%%
