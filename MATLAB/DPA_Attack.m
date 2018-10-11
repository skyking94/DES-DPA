%% Add paths 
addpath ./DES
addpath ./DPA


%% DPA Attack
% Aakash 07/29/2018


% KEY used for the Encryption of all the rounds
key = 10188139638837327643;
key64 = flip(dec2bin(key, 8) - '0');
%fprintf('The selected key is %x\n',doublearr2hex(key64));
% key64 = 001D9F7DA0D1C6B1

%% Generate plainText for performing partial Encryption = partialEncryptText





%% Generate partialEncrypt texts from the preprocessed plaintexts

% generate subkeys from the given key
%subkeys = DES_GenSubkeys(key64);

%SBOXnum = 2;
%STAGEno = 1;


% Generate plaintext in the format used by partial encrypt generator

fid  = fopen('./plaintext.txt');
numCiphers = 50000;
plain = correctinputCiphertexts(numCiphers, fid);
fclose(fid);

save('plainText.mat','plain');

tempplain = load('./plainText.mat');
plainText = tempplain.plain;


All64KeyGuesses = DPA_Gen64KeyGuessesForSBox(sBoxNumber, 1);
for guessItr=1:64
    for itr = 1:10 %broke up array calculation into 10 parts to reduce memory for parallel compuation in DES_partial
        indexesThisItr = [1:5000] + (itr-1) * 5000 ;
        partialEncryptText(guessItr,indexesThisItr,:) = logical(DES_partial(plainText(indexesThisItr,:),'ENC',All64KeyGuesses(guessItr,:),2,1));
    end
    guessItr
end


%% Rough work

if a == b
    fprintf('they match\n');
end




