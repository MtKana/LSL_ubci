%% initialize preprocess for BMI
cd('C:\Users\UshibaLab\01-individuals\matsuyanagi');
user_data = struct;
user_data.count = 0;

%% set para
Fs = 1000;
sec = 2;
COI = 1:128;

%% initialize EGI
LE = LSL_EGI_BMI(Fs,sec,COI,5);
LE = LE.set_buffer;

user_data.LSL_EGI_BMI = LE;
user_data.LSL_EGI_BMI = user_data.LSL_EGI_BMI.setup_protocol;

