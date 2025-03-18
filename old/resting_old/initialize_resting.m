%% initialize preprocess for BMI
cd('C:\Users\UshibaLab\01-individuals\matsuyanagi\resting');
user_data = struct;
user_data.count = 0;

%% set para
Fs = 1000;
sec = 2;
COI = 1:128;

%% initialize EGI
LE = LSL_EGI_resting(Fs,sec,COI, 2);
LE = LE.set_buffer;

user_data.LSL_EGI_resting = LE;
user_data.LSL_EGI_resting = user_data.LSL_EGI_resting.setup_protocol;