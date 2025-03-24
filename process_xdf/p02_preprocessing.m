order_index = 2;
final_eeg_file_name = 'JIN_rest_preprocssed.mat';

% Load EEG time series data
eeg_data = data_xdf{1, order_index}.time_series;  % 128 x timepoints
fs = 1000;  % Sampling frequency in Hz
duration_sec = 360;
samples_to_plot = 1:(fs * duration_sec);
channels_to_plot = [36, 104];  % C3 and C4

% Plot raw EEG
figure('Name','Raw EEG');
time_vector = (samples_to_plot - 1) / fs;
plot(time_vector, eeg_data(channels_to_plot, samples_to_plot)');
legend('C3','C4');
xlabel('Time (s)');
ylabel('Amplitude (µV)');
title('Raw EEG (C3 and C4)');

% Bandpass filter parameters
low_cutoff = 0.5;
high_cutoff = 45;
[b, a] = butter(4, [low_cutoff high_cutoff] / (fs / 2), 'bandpass');
filtered_eeg = filtfilt(b, a, double(eeg_data') )';  % Filtering

% Plot filtered EEG
figure('Name','Filtered EEG');
plot(time_vector, filtered_eeg(channels_to_plot, samples_to_plot)');
legend('C3','C4');
xlabel('Time (s)');
ylabel('Amplitude (µV)');
title('Filtered EEG (C3 and C4)');

% Load channel locations
chanlocs = readlocs('GSN-HydroCel-128.sfp');

% Create EEGLAB-compatible EEG structure
EEG = pop_importdata('dataformat','array','data','filtered_eeg','srate',fs,'chanlocs','GSN-HydroCel-128.sfp');

% Re-reference (common average)
EEG = pop_reref(EEG, [], 'refstate', 0);

% ICA for artifact removal
EEG = pop_runica(EEG, 'extended', 1, 'interupt', 'on');
EEG = pop_selectcomps(EEG, 1:20);  % Manual inspection
% Example: remove components 1 and 3
% EEG = pop_subcomp(EEG, [1 3], 0);

% Plot EEG after artifact removal
figure('Name','Cleaned EEG after ICA');
plot(time_vector, EEG.data(channels_to_plot, samples_to_plot)');
legend('C3','C4');
xlabel('Time (s)');
ylabel('Amplitude (µV)');
title('EEG after ICA (C3 and C4)');

% Save final EEG
save(final_eeg_file_name, 'EEG');