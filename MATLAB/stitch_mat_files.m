%%-----------------------------------------------------------------------
% 					Script to stitch the wave mat files
% -----------------------------------------------------------------------

%% Declare variables

matperWave = 40;
wave_count = 1;
wave_numbr = 1;

%% LOAD MAT files  

pathto_Results = "C:\Aakash\ITE313\MastersProject\matlab\results\";


%% WAVE 1 Stitching

a_load 		= load(strcat(pathto_Results,"wave1_50k_0.mat"));
a 		 	= a_load.wave1(~cellfun('isempty',a_load.wave1));
for i = 1:10000
   b{1, i} = a{1, i}(16921:38340);    
end
clear a
for itr = 1:matperWave-1
	new_load = load(strcat(pathto_Results,(strcat("wave1_50k_",(strcat(num2str(itr),".mat"))))));		%load mat file
	cleared_mat = new_load.wave1(~cellfun('isempty',new_load.wave1));	%clear empty cells
    index = 1;
    for index = 1:10000
        c{1, index} = cleared_mat{1, index}(16921:38340);    
    end
	if itr == 1
		concat_wave = horzcat(b, c);
	else
		concat_wave = horzcat(concat_wave, c);
    end
end
clear c
c = cell2mat(concat_wave);
clear concat_wave
c = permute(c, [2 1]);
traceDataAllCh(1,:,:) = c;

save('wave1.mat','concat_wave','-v7.3');

clear a b c a_load new_load cleared_mat concat_wave


%% WAVE 2 Stitching
a_load 		= load(strcat(pathto_Results,"wave2_50k_0.mat"));
a 		 	= a_load.wave2(~cellfun('isempty',a_load.wave2));
for i = 1:10000
   b{1, i} = a{1, i}(16921:38340);    
end

for itr = 1:matperWave-1
	new_load = load(strcat(pathto_Results,(strcat("wave2_50k_",(strcat(num2str(itr),".mat"))))));		%load mat file
	cleared_mat = new_load.wave2(~cellfun('isempty',new_load.wave2));	%clear empty cells
    index = 1;
    for index = 1:10000
        c{1, index} = cleared_mat{1, index}(16921:38340);    
    end
	if itr == 1
		concat_wave = horzcat(b, c);
	else
		concat_wave = horzcat(concat_wave, c);
    end
end

save('wave2.mat','concat_wave','-v7.3');

clear a b c a_load new_load cleared_mat concat_wave

%% WAVE 3 Stitching


a_load 		= load(strcat(pathto_Results,"wave3_50k_0.mat"));
a 		 	= a_load.wave3(~cellfun('isempty',a_load.wave3));
for i = 1:10000
   b{1, i} = a{1, i}(16921:38340);    
end
clear a
for itr = 1:matperWave-1
	new_load = load(strcat(pathto_Results,(strcat("wave3_50k_",(strcat(num2str(itr),".mat"))))));		%load mat file
	cleared_mat = new_load.wave3(~cellfun('isempty',new_load.wave3));	%clear empty cells
    index = 1;
    for index = 1:10000
        c{1, index} = cleared_mat{1, index}(16921:38340);    
    end
	if itr == 1
		concat_wave = horzcat(b, c);
	else
		concat_wave = horzcat(concat_wave, c);
    end
end
clear c
c = cell2mat(concat_wave);
clear concat_wave
c = permute(c, [2 1]);
traceDataAllCh(2,:,:) = c;

save('wave3.mat','concat_wave','-v7.3');

clear a b c a_load new_load cleared_mat concat_wave



%% Stitch all waveforms together

load wave1.mat concat_wave
wave1_mat = cell2mat(concat_wave);
wave1_mat = permute(wave1_mat, [2 1]);
traceDataAllCh(1,:,:) = wave1_mat;
clear wave1_mat concat_wave

% load wave2.mat concat_wave
% wave2_mat = cell2mat(concat_wave);
% wave2_mat = permute(wave2_mat, [2 1]);
% traceDataAllCh(2,:,:) = wave2_mat;
% clear wave2_mat concat_wave

load wave1.mat concat_wave
wave3_mat = cell2mat(concat_wave);
wave3_mat = permute(wave3_mat, [2 1]);
traceDataAllCh(2,:,:) = wave3_mat;
clear wave3_mat concat_wave

fprintf('done!\n');

