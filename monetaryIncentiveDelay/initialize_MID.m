%% initialize preprocess for BMI
cd('C:\Users\UshibaLab\01-individuals\matsuyanagi\monetaryIncentiveDelay');
user_data = struct;
user_data.count = 0;

%% set para
Fs = 1000;
sec = 2;
COI = 1:128;

%% initialize EGI
LE = LSL_EGI_MID(Fs,sec,COI, 3, 6);
LE = LE.set_buffer;

user_data.LSL_EGI_MID = LE;
user_data.LSL_EGI_MID = user_data.LSL_EGI_MID.setup_protocol;