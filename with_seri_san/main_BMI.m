%% initialize
close all

%% set para
Fs = 1000;
sec = 2;
COI = 1:128;

%% initialize EGI
LE = LSL_EGI_BMI(Fs,sec,COI,5);
LE = LE.set_buffer;
LE = LE.setup_protocol;

%% preprocess
while LE.state.trigger == 1
    LE = LE.process_eeg();
    LE = LE.show_protocol();
    pause(0.01);  % Pause to simulate real-time processing
end
