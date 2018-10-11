
fid = fopen('MATLAB_horz_DPA_plot.txt');

for itr = 1:2142
    line = fgetl(fid);
    data{1,itr} = line;
end

fclose(fid);

horzticks = []
for itr = 1:2142
    count = 0.0000001 * itr;
    horzticks = horzcat(horzticks, count);
end