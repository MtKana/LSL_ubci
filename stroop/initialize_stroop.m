%% initialize preprocess for BMI
cd('C:\Users\UshibaLab\01-individuals\matsuyanagi\stroop');
user_data = struct;
user_data.count = 0;

%% set para
Fs = 1000;
sec = 2;
COI = 1:128;

%% initialize EGI
LE = LSL_EGI_stroop(Fs,sec,COI, 3, 10);
LE = LE.set_buffer;

user_data.LSL_EGI_stroop = LE;
user_data.LSL_EGI_stroop = user_data.LSL_EGI_stroop.setup_protocol;