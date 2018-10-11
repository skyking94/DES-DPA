function KEY_A = correctinputCiphertexts(numCiphertexts, fid)

for itr = 1:numCiphertexts
   strCiphertext = fgetl(fid);
   %if length(strCiphertext(1,:)) == 16
   KEY_A(itr,:) = hexToBinaryVector(strCiphertext,64); 
end

