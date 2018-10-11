%%
%add paths to Scripts folder
addpath D:/Matlab/Script/instrument/
addpath D:/Matlab/Script/matlab_support_functions/
addpath D:/Matlab/Script/
addpath D:/aakash_mp/matlab/MatlabDES
addpath D:/aakash_mp/matlab/MatlabDES/DES
addpath D:/aakash_mp/matlab
%addpath C:/SVN/dpaboard/MATLAB



%% Necessary constants

captureTraces = 100; % specify number of power trace captures; ideal - 1e6
devicePort = 'COM4'; % specify the COM port where msp430 is

% cpuAddr = 50;
% %status register bit positions
% c = 1;
% z = 2;
% n = 3;
% gie = 4;
% cpuoff = 5;
% oscoff = 6;
% scg1 = 7;
% v = 8;
% startAddr = 'd000'; %Start address of program in hex



%% DES CONSTANT KEY
%key = round(rand(1,56)); %random generated key used for all the encryptions
%key_temp = [0; 1; 0; 0; 0; 0; 1; 1; 1; 0; 1; 1; 0; 1; 0; 0; 0; 0; 0; 0; 0; 0; 1; 1; 0; 0; 0; 1; 0; 0; 1; 0; 0; 0; 0; 0; 1; 1; 1; 0; 0; 0; 1; 0; 0; 0; 1; 1; 1; 0; 1; 0; 1; 0; 1; 0; 0; 1; 1; 0; 1; 1; 0; 0;];
%key = [1;0;1;1;1;1;0;0;0;1;0;0;1;0;1;1;1;1;1;1;1;1;0;0;1;1;1;0;1;1;0;1;1;1;1;1;0;0;0;1;1;1;0;1;1;1;0;0;0;1;0;1;0;1;0;1;1;0;0;1;0;0;1;1;];
% 0x8D638B05BEF9B71B
key = 10188139638837327643;
%temp = dec2bin(key64);
key64 = flip(dec2bin(key, 8) - '0');
%disp(key64);


%% Open serial port for communication with MSP430
%send the plaintext and keys via UART to MSP430
s = serial(devicePort,'BaudRate',115200,'DataBits',8,'StopBits',1,'Timeout',1000,'InputBufferSize',1e6,'OutputBufferSize',1e6);
fopen(s);


%% Initialize and check the instrument connection

visa_port = dpo7354c_init_visa;
% 
% %give initial DSO commands
dpo7354c_cmd(visa_port,'ACQ:STATE RUN');
pause(1);
dpo7354c_cmd(visa_port,'DAT:STAR 1');
dpo7354c_cmd(visa_port,'DAT:STOP 45000');

%% Ciphertext generation

ciphertexts = generate_ciphers(key64, captureTraces);
%disp(lfsr_val);


%% Bin file for programming the MSP430

% bin file for HW version
%binFile = fopen('D:\aakash_mp\c2bin\HW_C_code\main.bin','r');

% bin file for SW version
binFile = fopen('D:\aakash_mp\c2bin\SW_C_code\main.bin','r');


%% Programming the MSP430

% first check if CPU ID is correct, then proceed wwith programming the
% memory
%
% CALL DATACOMM FUNCTION 
%profile on
programMSP = datacomm_aakash(s, binFile);
%profile off
%profile viewer

%%
% Breakpoints verification
flushinput(s);
brkpt1 = {'48'};
brkpt2 = {'49'};
brkpt3 = {'0A'};
brkpt4 = {'0B'};

txdata_dec = hex2dec(brkpt1{1}); 
fwrite(s,txdata_dec,'uint8');          
BRKPT0 = fread(s,1,'uint8'); 
txdata_dec = hex2dec(brkpt2{1});
fwrite(s,txdata_dec,'uint8');
BRKPT1 = fread(s,1,'uint8'); 
fprintf("breakpoint CTL -- \n");
disp(BRKPT0);
fprintf("breakpoint STAT -- \n");
disp(BRKPT1);


txdata_dec = hex2dec(brkpt3{1}); 
fwrite(s,txdata_dec,'uint8');          
BRKPT2_low = fread(s,1,'uint8');
BRKPT2_high = fread(s, 1, 'uint8');
BRKPT2 = bitor(bitshift(BRKPT2_high,8),BRKPT2_low);
txdata_dec = hex2dec(brkpt4{1});  
fwrite(s,txdata_dec,'uint8');     
BRKPT3_low = fread(s,1,'uint8');
BRKPT3_high = fread(s, 1, 'uint8');
BRKPT3 = bitor(bitshift(BRKPT3_high,8),BRKPT3_low);
fprintf("breakpoint ADDR0 -- \n");
disp(BRKPT2);
fprintf("breakpoint ADDR1 -- \n");
disp(BRKPT3);



%==========================================================================
%% Script to connect to hardware MSP430 board via UART
%==========================================================================
%profile on
timerVal = tic;
% ----------------------------------------------------
%		MAIN LOOP
% ----------------------------------------------------
%cpuRunStatus = runCPU_aakash(s);

fid = fopen("ciphers.txt", "r");

for i = 1:captureTraces
    
%     %start / trigger oscilloscope - resolution set ?
%     dpo7354c_cmd(visa_port,'ACQUIRE:STATE ON\n');
%     % pause for a small time ?
%     dpo7354c_cmd(visa_port,'ACQUIRE:STOPAFTER SEQUENCE\n');
    
    %disp(cp2);
    %fflush(s);
    runCPU_aakash(s); % start next encryption and then collect data
    cipher_out = fgetl(fid);
    b = mod(i, 11);
    if b == 0
        disp(cipher_out);
    end
    
    %collect data from DSO
%     wave1{i+1}=int16(dpo7354c_read(visa_port,1));
%     %wave2{i+1}=int16(dpo7354c_read(visa_port,2));
%     wave3{i+1}=int16(dpo7354c_read(visa_port,3));
%     wave4{i+1}=int16(dpo7354c_read(visa_port,4));
    
    if s.BytesAvailable > 0
        for read_cnt = 1 : s.BytesAvailable
            cp2(read_cnt) = fread(s,1,'uint8');
            pause(0.1);
        end
        disp(cp2);
    end
    
end

%profile off
%profile viewer

elapsedtime = toc(timerVal);



%%
%     disp(lfsr_val(i))
% 	%create random values for 64 bit plaintext 
% 	temp = dec2bin(lfsr_val(i), 64);
% 	plaintext = double(temp - '0');
% 	
%     %perform DES encryption 
%     cp1 = DES(plaintext, 'ENC', key64); 
%     disp(cp1)
    %disp(key64)
    
      %%check with deepak  
    %run CPU command to start DES Encryption
    %run CPU command to make MSP430 start sending ciphertext
    %cpuRunStatus = runCPU(s);
    %wait till encryption gets done and output is available on RX buffer
    %tic
    %stop oscilloscope and store data
    
    %toc
    %read in the ciphertext2 from MSP430 and compare it with CP1
%     
%     %comparison passed ? resume the loop
%     if cp1 == cp2
%         fprintf('comparsion passed %d', captureTraces);
%     else
%         fprintf('mismatch b/w hardware and MATLAB values\n');
%         fprintf('Mismatch, %d -- MATLAB output', cp1(i));
%         fprintf('          %d -- MSP430 output', cp2);
%         break
%     end
    
    %comparsion failed ? exit the loop and display error

%disp(ciphertext)
%disp(key)



%pause(1);
%wait for MSP430 to encrypt and read back the data after encryption
%read ciphertext from MSP430
% for i = 1:8
% 	fread(s, hexCip(i), 'uint8');
%     pause(.1);
% end
% 
% %compare the received ciphertext with the one available
% if hexCip == ciphertext
% 	disp('comparison passed')
% else
% 	disp('comparison failed')
% end
% 
% %proceed with next plaintext if the current comparison is TRUE
% fclose(s);





    %fflush(s);
    %     % expect data back after every 1000 encryptions
    %     b = mod(i, 100);
    %     if b == 0
    % %         temp = dec2bin(lfsr_val(i), 64);
    % %         plaintext = double(temp - '0');
    % %         cp1 = DES(plaintext, 'ENC', key64);
    % %         fprintf("plaintext in use is %s\n", logical2hex(plaintext));
    % %         fprintf("computed ciphertext is %s\n", logical2hex(cp1));
    %         if s.BytesAvailable > 0
    %             for read_cnt = 1 : s.BytesAvailable
    %                 cp2(read_cnt) = fread(s,1,'uint8');
    %                 pause(0.1);
    %             end
    %         end
    %         %disp(cp2);
    %     end
    %
    %     if i == 1
    % %         temp = dec2bin(lfsr_val(i), 64);
    % %         plaintext = double(temp - '0');
    % %         cp1 = DES(plaintext, 'ENC', key64);
    % %         fprintf("plaintext in use is %s\n", logical2hex(plaintext));
    % %         fprintf("computed ciphertext is %s\n", logical2hex(cp1));
    %         if s.BytesAvailable > 0
    %             for read_cnt = 1 : s.BytesAvailable
    %                 cp2(read_cnt) = fread(s,1,'uint8');
    %                 pause(0.1);
    %             end
    %         end
    %         disp(cp2);
    %     end
    %
    %     if s.BytesAvailable > 0
    %         for read_cnt = 1 : s.BytesAvailable
    %             cp2(read_cnt) = fread(s,1,'uint8');
    %             pause(0.1);
    %         end
    %     end
    %disp(cp2);