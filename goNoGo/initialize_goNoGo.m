%% initialize preprocess for BMI
cd('C:\Users\UshibaLab\01-individuals\matsuyanagi\goNoGo');
user_data = struct;
user_data.count = 0;

%% set para
Fs = 1000;
sec = 2;
COI = 1:128;

%% initialize EGI
LE = LSL_EGI_goNoGo(Fs,sec,COI, 3, 4, 0.7);
LE = LE.set_buffer;

user_data.LSL_EGI_goNoGo = LE;
user_data.LSL_EGI_goNoGo = user_data.LSL_EGI_goNoGo.setup_protocol;