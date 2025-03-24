%% initialize preprocess for BMI
cd('C:\Users\UshibaLab\01-individuals\matsuyanagi\goNoGo');
user_data = struct;
user_data.count = 0;

%% set para
Fs = 1000;
sec = 2;
COI = 1:128;

%% initialize EGI
% LD = LSL_DAQ_goNoGo(Fs,sec,COI, 3, 10, 0.7);
LD = LSL_DAQ_goNoGo(Fs,sec,COI, 4, 50, 0.7);
LD = LD.set_buffer;

user_data.LSL_DAQ_goNoGo = LD;
user_data.LSL_DAQ_goNoGo = user_data.LSL_DAQ_goNoGo.setup_protocol;