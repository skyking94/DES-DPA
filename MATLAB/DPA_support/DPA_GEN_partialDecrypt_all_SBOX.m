addpath ./matlab_support_functions/
pathPrefix = '/mnt/raid2/share/DPAData/';

%partialDecryptText_4keys_8Sbox = zeros(4,8,64,1000000000,64);

mymatlabpool(12)

send_email('nobody@cs.umbc.edu','robucci.umbc@gmail.com','starting<eom>','');


for keyItr = 1:4
    switch(keyItr)
        case 1
            keyLabel='A';
            load /mnt/raid2/share/DPAData/Ciphertext_1M/cipherText_KeyA cipherText
        case 2
            keyLabel='B';
            load /mnt/raid2/share/DPAData/Ciphertext_1M/cipherText_KeyB cipherText
        case 3
            keyLabel='AInv';
            load /mnt/raid2/share/DPAData/Ciphertext_1M/cipherText_KeyAInv cipherText
        case 4
            keyLabel='BInv';
            load /mnt/raid2/share/DPAData/Ciphertext_1M/cipherText_KeyBInv cipherText
    end
    
    tic
    %for sBoxNumber = 1:8
    All64KeyGuesses = DPA_Gen64KeyGuessesForSBox(sBoxNumber, 1);
    for guessItr=1:64        
        for itr = 1:10 %broke up array calculation into 10 parts to reduce memory for parallel compuation in DES_partial
            indexesThisItr = [1:5000] + (itr-1) * 5000 ;
            %tic
            partialDecryptText(guessItr,indexesThisItr,:) = logical(DES_partial(cipherText(indexesThisItr,:),'DEC',All64KeyGuesses(guessItr,:),2,1)); %before last sbox use
            %toc %took 4 seconds
        end
        guessItr
    end
    %filepath = strcat(pathPrefix,'partialDecryptText_','Key',keyLabel,'_SBOX',num2str(sBoxNumber),'.mat');
    %save(filepath,'partialDecryptText','-v7.3');
    %send_email('nobody@cs.umbc.edu','robucci.umbc@gmail.com','done',sprintf('sBoxNumber = %d',sBoxNumber));
    %end
    toc % ~22000 secs
end


