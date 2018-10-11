function attackBitNumber = DPA_FindAttackBitIndexInPartialDecipher(whichSBox,whichSBoxOutputBit)
%whichSBox 1-8
%whichSBoxOutputBit 1-4
%see comments at end of source code for full table of attack bit numbers

temp = zeros(1,32);
temp([1:4]+(whichSBox-1)*4)=[1 1 1 1];
e_indexes = find(DES_PBOX(temp)); %use DES PBOX to reorder (permutate) bits
cipherTextIndexes = e_indexes + 32;
AttackBitNumbers4 = cipherTextIndexes;
attackBitNumber =  AttackBitNumbers4(whichSBoxOutputBit);


%for sbn=1:8,
%    for bn = 1:4,
%       fprintf('sbn = %d, bn = %d abn = %d\n',sbn,bn,DPA_FindAttackBitIndexInPartialDecipher(sbn,bn));
%    end
%end
% sbn = 1, bn = 1 abn = 41
% sbn = 1, bn = 2 abn = 49
% sbn = 1, bn = 3 abn = 55
% sbn = 1, bn = 4 abn = 63
% sbn = 2, bn = 1 abn = 34
% sbn = 2, bn = 2 abn = 45
% sbn = 2, bn = 3 abn = 50
% sbn = 2, bn = 4 abn = 60
% sbn = 3, bn = 1 abn = 38
% sbn = 3, bn = 2 abn = 48
% sbn = 3, bn = 3 abn = 56
% sbn = 3, bn = 4 abn = 62
% sbn = 4, bn = 1 abn = 33
% sbn = 4, bn = 2 abn = 42
% sbn = 4, bn = 3 abn = 52
% sbn = 4, bn = 4 abn = 58
% sbn = 5, bn = 1 abn = 35
% sbn = 5, bn = 2 abn = 40
% sbn = 5, bn = 3 abn = 46
% sbn = 5, bn = 4 abn = 57
% sbn = 6, bn = 1 abn = 36
% sbn = 6, bn = 2 abn = 43
% sbn = 6, bn = 3 abn = 51
% sbn = 6, bn = 4 abn = 61
% sbn = 7, bn = 1 abn = 39
% sbn = 7, bn = 2 abn = 44
% sbn = 7, bn = 3 abn = 54
% sbn = 7, bn = 4 abn = 64
% sbn = 8, bn = 1 abn = 37
% sbn = 8, bn = 2 abn = 47
% sbn = 8, bn = 3 abn = 53
% sbn = 8, bn = 4 abn = 59