function which6BitIndexesInKey64 = DPA_FindBitIndexesOfInterestInKey64(sBoxNumber, whichStage)
%sbox number should be 1-8
%see DES_partial for whichState, should likely be 16 -- for last round attack

whichSubKeyBits =  [1:6]+(sBoxNumber-1)*6;
subKeyMapping = DES_GenSubkeys(1:64);
which6BitIndexesInKey64 = subKeyMapping(whichStage,whichSubKeyBits);
