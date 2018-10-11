function hex = logical2hex(logical_in)

full = size(logical_in);
half = full(2)/2;
hi_dblwrd = logical_in(1:half);
lo_dblwrd = logical_in(half+1:full(2));
a = {hi_dblwrd, lo_dblwrd}; %some cell array with logical values inside
%Turning into a string and then into a decimal number
temp = cellfun(@(x) bin2dec(sprintf('%i',x)),a);

hex_hi = dec2hex(temp(1));
hex_lo = dec2hex(temp(2));
out = [hex_hi, hex_lo];
hex = join(out);