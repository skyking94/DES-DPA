function hex = doublearr2hex(dblarry)

arr_size = size(dblarry);
out = zeros(1,arr_size(2));

for itr = 1:arr_size(2)    
    temp = dec2hex(dblarry(itr));
    out(:,itr) = temp;    
end

hex = join(out);
