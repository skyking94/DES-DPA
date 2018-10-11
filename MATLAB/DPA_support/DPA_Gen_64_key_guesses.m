keyGuess_guessIndex_bitNumber_logical = Gen64KeyGuesses()

%% Generate 64 Possible key guesses for SBOXes with other bits set to zero
%determing subkey mapping going into 16th stage
% subKeyMapping = DES_GenSubkeys(1:64)
whichStage = 16;

keyGuess_guessIndex_bitNumber_logical = (zeros(64,64))==1;

for keyGuessIndex = 0:63,
    bv6_keyGuess = dec2bin(keyGuessIndex,6)-'0'; %6-bit version of guess index
    for sBoxNumber=1:8,
        
        whichSubKeyBits =  [1:6]+(sBoxNumber-1)*6
        subKeyMapping = DES_GenSubkeys(1:64);
        keyBitsOfInterest6 = subKeyMapping(whichStage,whichSubKeyBits);
        keyGuess_logical64(keyBitsOfInterest6) =  bv6_keyGuess=='1';
    end
    keyGuess_logical64(keyGuessIndex,:) = DES_SetParityInKey(keyGuess_logical64(keyGuessIndex,:)); %not needed, but go ahead and put in the correct partity bits
end


%
%%% Extract value of bit of interest
%whichSBox=5
%bitIndexesOfInterestOutOfSBox= ((whichSBox-1)*4+[1:4]);
%v32 = zeros(1,32);
%v32(bitIndexesOfInterestOutOfSBox)=[1,1,1,1];
%bitIndexesOfInterest = find(DES_PBOX(v32))


