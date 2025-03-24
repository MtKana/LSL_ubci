%% initialize preprocess for BMI
cd('C:\Users\UshibaLab\01-individuals\matsuyanagi\oddball');
user_data = struct;
user_data.count = 0;

%% set para
Fs = 1000;
sec = 2;
COI = 1:128;

%% initialize EGI
% LD = LSL_DAQ_oddball(Fs,sec,COI, 3, 10);
LD = LSL_DAQ_oddball(Fs,sec,COI, 4, 50);
LD = LD.set_buffer;

user_data.LSL_DAQ_oddball = LD;
user_data.LSL_DAQ_oddball = user_data.LSL_DAQ_oddball.setup_protocol;