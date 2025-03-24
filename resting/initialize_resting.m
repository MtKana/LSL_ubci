%% initialize preprocess for BMI
cd('C:\Users\UshibaLab\01-individuals\matsuyanagi\resting');
user_data = struct;
user_data.count = 0;

%% set para
Fs = 10000;
sec = 2;
COI = 1:4;

%% initialize DAQ
LD = LSL_DAQ_resting(Fs,sec,COI, 2);
LD = LD.set_buffer;

user_data.LSL_DAQ_resting = LD;
user_data.LSL_DAQ_resting = user_data.LSL_DAQ_resting.setup_protocol;