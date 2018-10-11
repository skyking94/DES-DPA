function [ dpaTrace_CGT ] = DPATracerWrapper( varargin )
if strcmp(varargin{1},'C')
    dpaTrace_CGT = DPATracer(varargin{2:end});
else    
    traceDataAllCh= varargin{2};
    itrStart= varargin{3};
    itrEnd= varargin{4};
    partialEncryptText= varargin{5};
    attackBitNumber= varargin{6};
    guessMax= varargin{7};
    numthreads= varargin{8};
    traceRange = itrStart:itrEnd;
    numScopePoints = 21420;
    dpaTrace_CGT= zeros(2,64,numScopePoints);
    for guessItr=1:64
        group0Indexes=itrStart-1+find(partialEncryptText(guessItr,traceRange,attackBitNumber)==0);
        group1Indexes=itrStart-1+find(partialEncryptText(guessItr,traceRange,attackBitNumber)==1);
 
        trace0MeanCh1 = mean(squeeze(traceDataAllCh(1,group0Indexes,:)),1);
        trace1MeanCh1 = mean(squeeze(traceDataAllCh(1,group1Indexes,:)),1);
        trace0MeanCh3 = mean(squeeze(traceDataAllCh(2,group0Indexes,:)),1);
        trace1MeanCh3 = mean(squeeze(traceDataAllCh(2,group1Indexes,:)),1);
        
        dpaTrace_CGT(1,guessItr,:) = trace0MeanCh1 - trace1MeanCh1;
        dpaTrace_CGT(2,guessItr,:) = trace0MeanCh3 - trace1MeanCh3;
    end
end
