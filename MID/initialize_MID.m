%% initialize preprocess for BMI
cd('C:\Users\UshibaLab\01-individuals\matsuyanagi\MID');
user_data = struct;
user_data.count = 0;

%% set para
Fs = 1000;
sec = 2;
COI = 1:128;

%% initialize DAQ
% LD = LSL_DAQ_MID(Fs,sec,COI, 3, 12);
LD = LSL_DAQ_MID(Fs,sec,COI, 4, 51);
LD = LD.set_buffer;

user_data.LSL_DAQ_MID = LD;
user_data.LSL_DAQ_MID = user_data.LSL_DAQ_MID.setup_protocol;