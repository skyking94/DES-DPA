function keyGuess_guessIndex_bitNumber_logical = DPA_Gen64KeyGuessesForSBox(sBoxNumber,whichStage)

%% Generate 64 Possible key guesses for an SBOX with other bits set to zero
%determing subkey mapping going into 16th stage
% subKeyMapping = DES_GenSubkeys(1:64)
%see DES_partial for whichState, should likely be 16 -- for last round attack


keyGuess_guessIndex_bitNumber_logical = (zeros(64,64))==1;


keyBitsIndexesOfInterest6 = DPA_FindBitIndexesOfInterestInKey64(sBoxNumber,whichStage);

for keyGuessIndex = 0:63
    bv6_keyGuess = dec2bin(keyGuessIndex,6)-'0'; %6-bit version of guess index
%     
    keyGuess = zeros(1,64)==1;
    keyGuess(keyBitsIndexesOfInterest6) =  bv6_keyGuess==1;
    
    %not needed, but go ahead and put in the correct partity bits
    keyGuess_guessIndex_bitNumber_logical(keyGuessIndex+1,:) = DES_SetParityInKey(keyGuess);
   % keyGuessIndex
%     for sBoxNumber=1:8
%         
%         whichSubKeyBits = [1:6]+(sBoxNumber-1)*6;
%         subKeyMapping = DES_GenSubkeys(1:64);
%         keyBitsOfInterest6 = subKeyMapping(whichStage,whichSubKeyBits);
%         keyGuess_logical64(keyBitsOfInterest6) =  bv6_keyGuess=='1';
%     end
%     keyGuess_logical64(keyGuessIndex+1,:) = DES_SetParityInKey(keyGuess_logical64(keyGuessIndex+1,:));
end


%
%%% Extract value of bit of interest
%whichSBox=5
%bitIndexesOfInterestOutOfSBox= ((whichSBox-1)*4+[1:4]);
%v32 = zeros(1,32);
%v32(bitIndexesOfInterestOutOfSBox)=[1,1,1,1];
%bitIndexesOfInterest = find(DES_PBOX(v32))


