%DPA attck script you have to enter sbox and key
%i= key
%j = sbox
 %% Accepts user inputs
  
 
%  prompt = 'Which key among (1,2,3,4) you want to attck? ';
%  i = input(prompt)
%  
%  
%  %%Which sbox should be in range [1-8]
%  prompt = 'Which sbox you want to attck? ';
%  j = input(prompt)
% 
%  
%  prompt = 'Which Experiment data you want to attack??'
%  
%  k= input(prompt)
tic
i = 1;
 %%% i is key and should be in range [1-4]
 %%% 1 = key1(65448D0317B265B1)
 %%% 2 = key2(43B403120E23AA6C)
 %%% 3 = key1_inverse(9ABB72FCE84D9A4E)
 %%% 4 = key2_inverse((17897F9DBE3B8AB2)
j = 1;
%j is which SBOX and should be in range [1-8]
k = 1;
% k is which experiments and should be in range [1-8]
S= fetch_input_data(i,j,k);
toc

%%

[All64KeyGuesses,partialDecryptText,itr,traceDataAllCh] 

 
  %% Compute Which Bits in the 1-round decrypt data we should be looking at
 %j=1
 %cipherTextIndexes will be 4 values each in range [1-64]
 whichSBox = j;
 temp = zeros(1,32);
 temp([1:4]+(whichSBox-1)*4)=[1 1 1 1];
 e_indexes = find(DES_PBOX(temp)); %use DES PBOX to reorder (permutate) bits
 cipherTextIndexes = e_indexes + 32
 AttackBitNumbers = cipherTextIndexes
 
 prompt = 'Enter which bit amongst attack bit numbers you want to attack'
 attackBitNumber = input(prompt)
 %attackBitNumber = a
%% Loads Data file based on SBOX,Key and Experiment
%%%%%INPUTS TO BELOW
% itr_count int number of traces, typically 1M for us
% partialDecryptText logical: 64 (guess key itr) x 1M (trace itr) x 64 (partial ciphertext bit itr)
% attackBitNumber int in range 1-64
%traceDataAllCh 4 (channels) x 1M (trace itr, 1M may be value of itr_count) x 500 (number of scope points)


%  pathPrefix_key = '/mnt/raid2/share/DPA/SBOX/Key_Guess_all_sbox/All64KeyGuesses_s';
%  %\\covail.cs.umbc.edu\share\DPA\SBOX\Key_Guess_all_sbox
%  
%  filepath_key = strcat(pathPrefix_key,num2str(j),'.mat');
%  
%  load(filepath_key)
%  
%  
%  pathPrefix_partial = '/mnt/raid2/share/DPA/SBOX/PartialDecryptText_all_sbox/partialDecryptText_';
%  
%  filepath_partial = strcat(pathPrefix_partial,num2str(i),num2str(j),'.mat');
%  
%  load(filepath_partial)
%  
%  %% Computes path to load  1 million traces data
%  % which experiments are in range [1-8]
%  pathPrefix_exp = '/mnt/raid2/share/DPA/Experiment_';
%  
%  filepath_exp = strcat(pathPrefix_exp,num2str(k),'/Traces1M','.mat');
%  load(filepath_exp)
%  
%  %\\covail.cs.umbc.edu\share\DPA\Experiment_1
%  
%  
% 
%  %% computes Dpa traces
%  
% [m,n]=size(traceDataCh1);
% traceDataAllCh = zeros(4,m,n,'int16');
% %[m,n]=size(traceDataAllCh1_2M);
% %traceDataAllCh = zeros(1,m,n,'int16');
% 
% 
% traceDataAllCh(1,:,:)=traceDataCh1;
% traceDataAllCh(2,:,:)=traceDataCh2;
% traceDataAllCh(3,:,:)=traceDataCh3;
% traceDataAllCh(4,:,:)=traceDataCh4;


 %All64KeyGuesses = All64KeyGuesses_s;

 
 
attackData = traceDataAllCh;

%itr = 2000001;
%traceRange = 482007:itr; %assumes itr is last itr from experiment run
traceRange = 1:itr_count-1; %
%traceRange = 482007:itr-1;

%attackBitNumber=49; %41,49,55,63    ... choices made obvious by -> std(double(squeeze(partialDecryptText(:,1000,:))))
%attackBitNumber=41; %41,49,55,63   ... choices made obvious by -> std(double(squeeze(partial(:,1000,:))))  
%attackBitNumbers={41,49,55,63};

tic
% f1 = fopen('/mnt/raid2/share/DESindex.arff','at');
% 
% fprintf(f1,'@relation ZeroOne \n\r\n\r@attribute iteration numeric \n\r@attribute subset {zero,one} \n\r@attribute index numeric \n\r\n\r@data\n\r');

for guessItr=1:length(All64KeyGuesses)
    
    group0Indexes=find(partialDecryptText(guessItr,traceRange,attackBitNumber)==0);
    group1Indexes=find(partialDecryptText(guessItr,traceRange,attackBitNumber)==1);
    
    trace0MeanCh1 = mean(squeeze(attackData(1,group0Indexes,:)),1);
    trace1MeanCh1 = mean(squeeze(attackData(1,group1Indexes,:)),1);
    %figure(1000);
    %hold all
    %plot(trace0MeanCh1,'b')



    trace0MeanCh2 = mean(squeeze(attackData(2,group0Indexes,:)),1);
    trace1MeanCh2 = mean(squeeze(attackData(2,group1Indexes,:)),1);
    %plot(trace0MeanCh2,'g')
    
    trace0MeanCh3 = mean(squeeze(attackData(3,group0Indexes,:)),1);
    trace1MeanCh3 = mean(squeeze(attackData(3,group1Indexes,:)),1);
    %figure(1000);
    
    %hold all
   % plot(trace0MeanCh3)
     
    
    trace0MeanCh4 = mean(squeeze(attackData(4,group0Indexes,:)),1);
    trace1MeanCh4 = mean(squeeze(attackData(4,group1Indexes,:)),1);
    %plot(trace0MeanCh4,'r')
    
    dpaTraceCh1{guessItr} = trace0MeanCh1 - trace1MeanCh1;
    dpaTraceCh2{guessItr} = trace0MeanCh2 - trace1MeanCh2;
    dpaTraceCh3{guessItr} = trace0MeanCh3 - trace1MeanCh3;
    dpaTraceCh4{guessItr} = trace0MeanCh4 - trace1MeanCh4;
    guessItr
    %hold all;
%     for i = 1:length(group0Indexes)
%         fprintf(f1, '%d,zero,%d\n\r',guessItr,group0Indexes(1,i));
%     end
%     for i = 1:length(group1Indexes)
%         fprintf(f1, '%d,one,%d\n\r',guessItr,group1Indexes(1,i));
%     end
    
  % save   ('/mnt/raid2/share/group0Indexes.mat', 'guessItr','group0Indexes', '-v7.3')
  %  save   ('/mnt/raid2/share/group1Indexes.mat', 'guessItr','group1Indexes', '-v7.3')

end
% fclose(f1);

toc %193sec (67 to 500 depending on server load) ,40 for deskew data


%%
%% plot dpa traces with correct-key trace overlay


%tt=1:length(trace0MeanCh1{1});
tt=1:length(dpaTraceCh1{1});
figure;
for guessItr=1:64
    labelText=sprintf('%d',guessItr);
    guessItr
    temph(1)=subplot(2,2,1);
    %plot(traceDataCh1)
    %plot(tt,traceDataAllCh{guessItr},'DisplayName',labelText); hold all;title('ch1');
    plot(tt,dpaTraceCh1{guessItr},'DisplayName',labelText); hold all;title('ch1');
    temph(1)=subplot(2,2,2);
    plot(tt,dpaTraceCh2{guessItr},'DisplayName',labelText);hold all;title('ch2');
    temph(1)=subplot(2,2,3);
    plot(tt,dpaTraceCh3{guessItr},'DisplayName',labelText);hold all;title('ch3');
    temph(1)=subplot(2,2,4);
    plot(tt,dpaTraceCh4{guessItr},'DisplayName',labelText);hold all;title('ch4');
    setgridcolor([.7 .7 .7]);
    %vline(0,'k');
    %vline(-100e-9,'k');
    %legend('show')
end
%linkaxes(temph)
%plot(tt,dpaTraceCh1{guessItr},'DisplayName',labelText); hold all;title('ch1');
%plot correct key in orange
%% computes guessItr based on ALL64KeyGuesses and key

%key = [1; 0; 0; 0; 1; 1; 0; 1; 1; 0; 1; 0; 0; 1; 1; 0; 0; 1; 0; 0; 1; 1; 0; 1; 1; 1; 1; 0; 1; 0; 0; 0; 1; 1; 0; 0; 0; 0; 0; 0; 1; 0; 1; 1; 0; 0; 0; 1; 0; 0; 1; 0; 0; 0; 1; 0; 1; 0; 1; 0; 0; 1; 1; 0;]
%key2 = [0; 1; 0; 0; 0; 0; 1; 1; 1; 0; 1; 1; 0; 1; 0; 0; 0; 0; 0; 0; 0; 0; 1; 1; 0; 0; 0; 1; 0; 0; 1; 0; 0; 0; 0; 0; 1; 1; 1; 0; 0; 0; 1; 0; 0; 0; 1; 1; 1; 0; 1; 0; 1; 0; 1; 0; 0; 1; 1; 0; 1; 1; 0; 0;]
%key_inverse = ~key;
%key_inverse = ~key;

%key_temp =key_inverse';
%key_temp = ~ key2';

if (  i == 1)
    key = [1; 0; 0; 0; 1; 1; 0; 1; 1; 0; 1; 0; 0; 1; 1; 0; 0; 1; 0; 0; 1; 1; 0; 1; 1; 1; 1; 0; 1; 0; 0; 0; 1; 1; 0; 0; 0; 0; 0; 0; 1; 0; 1; 1; 0; 0; 0; 1; 0; 0; 1; 0; 0; 0; 1; 0; 1; 0; 1; 0; 0; 1; 1; 0;]
    key_temp = key';
end

if ( i == 2)
    key = [0; 1; 0; 0; 0; 0; 1; 1; 1; 0; 1; 1; 0; 1; 0; 0; 0; 0; 0; 0; 0; 0; 1; 1; 0; 0; 0; 1; 0; 0; 1; 0; 0; 0; 0; 0; 1; 1; 1; 0; 0; 0; 1; 0; 0; 0; 1; 1; 1; 0; 1; 0; 1; 0; 1; 0; 0; 1; 1; 0; 1; 1; 0; 0;]
    key_temp = key';
%key_inverse = ~key;
end

if ( i == 3)
    key = [1; 0; 0; 0; 1; 1; 0; 1; 1; 0; 1; 0; 0; 1; 1; 0; 0; 1; 0; 0; 1; 1; 0; 1; 1; 1; 1; 0; 1; 0; 0; 0; 1; 1; 0; 0; 0; 0; 0; 0; 1; 0; 1; 1; 0; 0; 0; 1; 0; 0; 1; 0; 0; 0; 1; 0; 1; 0; 1; 0; 0; 1; 1; 0;]
    key_temp = ~key';
end

if( i == 4)
     key = [0; 1; 0; 0; 0; 0; 1; 1; 1; 0; 1; 1; 0; 1; 0; 0; 0; 0; 0; 0; 0; 0; 1; 1; 0; 0; 0; 1; 0; 0; 1; 0; 0; 0; 0; 0; 1; 1; 1; 0; 0; 0; 1; 0; 0; 0; 1; 1; 1; 0; 1; 0; 1; 0; 1; 0; 0; 1; 1; 0; 1; 1; 0; 0;]
     key_temp = ~key';
end
% which bits
%for Sbox = 1:8
whichStage = 16;
 if (j == 1)
        whichSubKeyBits = 1:6;
    end
    
    if (j == 2)
        whichSubKeyBits = 7:12;
    end
    
    if (j == 3)
        whichSubKeyBits = 13:18;
    end
    
    if (j == 4)
        whichSubKeyBits = 19:24;
    end
    
    if (Sbox == 5)
        whichSubKeyBits = 25:30;
    end
    
    if (j == 6)
        whichSubKeyBits = 31:36;
    end
    
    
    if (j == 7)
        whichSubKeyBits = 37:42;
    end
    
    if (j == 8)
        whichSubKeyBits = 43:48;
    end
    
%end

%%computes 6 bits of interest in key
subKeyMapping = DES_GenSubkeys(1:64);
keyBitsOfInterest6 = subKeyMapping(whichStage,whichSubKeyBits);
%key_temp =key_inverse';
%key_temp = ~ key2';
load '/mnt/raid2/share/DPA/SBOX/Key_Guess_all_sbox/All64KeyGuesses_s2.mat'
for Guess_Itrs = 1:64
    %guesskey;
    %tempkey = char('0'+reshape(fliplr(All64KeyGuesses(itr,:)),8,8))';
    %if((key_temp(1,3) == All64KeyGuesses(Guess_Itrs,3)) && (key_temp(1,18) == All64KeyGuesses(Guess_Itrs,18)) && (key_temp(1,25) == All64KeyGuesses(Guess_Itrs,25)) && (key_temp(1,42) == All64KeyGuesses(Guess_Itrs,42)) && (key_temp(1,57) == All64KeyGuesses(Guess_Itrs,57)) && (key_temp(1,59) == All64KeyGuesses(Guess_Itrs,59)))
  % if((key_temp (1,keyBitsOfInterest6(1)) == All64KeyGuesses(Guess_Itrs,keyBitsOfInterest6(1)))&& key_temp (1,keyBitsOfInterest6(2) == All64KeyGuesses(Guess_Itrs,keyBitsOfInterest6(2))) && (key_temp (1,keyBitsOfInterest6(3)) == All64KeyGuesses(Guess_Itrs,keyBitsOfInterest6(3))) ...
       %    && (key_temp (1,keyBitsOfInterest6(4)) == All64KeyGuesses(Guess_Itrs,keyBitsOfInterest6(4))) && (key_temp (1,keyBitsOfInterest6(5)) == All64KeyGuesses(Guess_Itrs,keyBitsOfInterest6(5))) && (key_temp (1,keyBitsOfInterest6(6)) == All64KeyGuesses(Guess_Itrs,keyBitsOfInterest6(6))) ) 
    if((key_temp(1,keyBitsOfInterest6(1)) == All64KeyGuesses(Guess_Itrs,keyBitsOfInterest6(1))) && (key_temp(1,keyBitsOfInterest6(2)) == All64KeyGuesses(Guess_Itrs,keyBitsOfInterest6(2))) && (key_temp(1,keyBitsOfInterest6(3)) == All64KeyGuesses(Guess_Itrs,keyBitsOfInterest6(3))) && (key_temp(1,keyBitsOfInterest6(4)) == All64KeyGuesses(Guess_Itrs,keyBitsOfInterest6(4))) && ...
          (key_temp(1,keyBitsOfInterest6(5)) == All64KeyGuesses(Guess_Itrs,keyBitsOfInterest6(5))) && (key_temp(1,keyBitsOfInterest6(6)) == All64KeyGuesses(Guess_Itrs,keyBitsOfInterest6(6))))    
          Guess_Itrs
          guessItr = Guess_Itrs
         
    end
end

 
%%% 1 = key1(65448D0317B265B1)
 %%% 2 = key2(43B403120E23AA6C)
 %%% 3 = key1_inverse(9ABB72FCE84D9A4E)
 %%% 4 = key2_inverse((17897F9DBE3B8AB2)

%guessItr=52;         %key1
%guessItr=13;          %key1_inverse 
%guessItr=17;          %key2
%guessItr = 48;        %key2_inverse


labelText=sprintf('%d',guessItr);
temph(1)=subplot(2,2,1);
plot(tt,dpaTraceCh1{guessItr},'--','LineWidth',3,'DisplayName',labelText,'Color',[1 .5 0]); hold all;title('ch1');
temph(1)=subplot(2,2,2);
plot(tt,dpaTraceCh2{guessItr},'--','LineWidth',3,'DisplayName',labelText,'Color',[1 .5 0]);hold all;title('ch2');
temph(1)=subplot(2,2,3);
plot(tt,dpaTraceCh3{guessItr},'--','LineWidth',3,'DisplayName',labelText,'Color',[1 .5 0]);hold all;title('ch3');
temph(1)=subplot(2,2,4);
plot(tt,dpaTraceCh4{guessItr},'--','LineWidth',3,'DisplayName',labelText,'Color',[1 .5 0]);hold all;title('ch4');



All64KeyGuesses(guessItr,:) == actualKeyParityCorrect

%for itr = 1:64
%    itr
%    char('0'+(actualKeyParityCorrect == guessKey{itr}))
%end


% if experimentItr==0
%     save rightKeyBigExp2
% else
%     save wrongKeyBigExp2
% end


%% plot function of dpa traces with correct-key trace overlay

%myfun = inline('(abs(fft(x(250+[-50:50]))))')
%myfun = inline('(abs(fft(x(225+[-25:25]))))')
myfun = inline('(abs(fft(x(200+[-50:50]))))')
%myfun = inline('(abs(fft(x(230+[-20:20]))))')




tt=1:length(dpaTraceCh1{1});
figure;
for guessItr=1:64
    labelText=sprintf('%d',guessItr);
    temph(1)=subplot(2,2,1);
    plot(myfun(dpaTraceCh1{guessItr}),'DisplayName',labelText); hold all;title('ch1');
    temph(1)=subplot(2,2,2);
    plot(myfun(dpaTraceCh2{guessItr}),'DisplayName',labelText);hold all;title('ch2');
    temph(1)=subplot(2,2,3);
    plot(myfun(dpaTraceCh3{guessItr}),'DisplayName',labelText);hold all;title('ch3');
    temph(1)=subplot(2,2,4);
    plot(myfun(dpaTraceCh4{guessItr}),'DisplayName',labelText);hold all;title('ch4');
    setgridcolor([.7 .7 .7]);
    %vline(0,'k');
    %vline(-100e-9,'k');
    %legend('show')
end
%linkaxes(temph)

%plot correct key in orange
%guessItr=52;
%guessItr=13;
%guessItr=17;
%guessItr=48;


labelText=sprintf('%d',guessItr);
temph(1)=subplot(2,2,1);
plot(myfun(dpaTraceCh1{guessItr}),'--','LineWidth',3,'DisplayName',labelText,'Color',[1 .5 0]); hold all;title('ch1');
temph(1)=subplot(2,2,2);
plot(myfun(dpaTraceCh2{guessItr}),'--','LineWidth',3,'DisplayName',labelText,'Color',[1 .5 0]);hold all;title('ch2');
temph(1)=subplot(2,2,3);
plot(myfun(dpaTraceCh3{guessItr}),'--','LineWidth',3,'DisplayName',labelText,'Color',[1 .5 0]);hold all;title('ch3');
temph(1)=subplot(2,2,4);
plot(myfun(dpaTraceCh4{guessItr}),'--','LineWidth',3,'DisplayName',labelText,'Color',[1 .5 0]);hold all;title('ch4');



All64KeyGuesses(guessItr,:) == actualKeyParityCorrect





