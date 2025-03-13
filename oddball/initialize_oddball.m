%% initialize preprocess for BMI
cd('C:\Users\UshibaLab\01-individuals\matsuyanagi\oddball');
user_data = struct;
user_data.count = 0;

%% set para
Fs = 1000;
sec = 2;
COI = 1:128;

%% initialize EGI
LE = LSL_EGI_oddball(Fs,sec,COI, 3, 50);
LE = LE.set_buffer;

user_data.LSL_EGI_oddball = LE;
user_data.LSL_EGI_oddball = user_data.LSL_EGI_oddball.setup_protocol;