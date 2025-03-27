%% MATLAB Script to Inspect and Analyze an XDF File from U-BCI

clc; clear; close all;

%% Load EEGLAB if needed
if ~exist('load_xdf', 'file')
    disp('Loading EEGLAB...');
    eeglab; % Open EEGLAB (ensure you have the XDF plugin installed)
end

%% Select XDF File
[file, path] = uigetfile('*.xdf', 'Select the XDF file');
if isequal(file, 0)
    disp('File selection canceled.');
    return;
end
xdf_filepath = fullfile(path, file);
disp(['Loading XDF file: ', xdf_filepath]);

%% Load XDF File
data = load_xdf(xdf_filepath);

%% Display Available Streams
disp('Streams found in the XDF file:');
for i = 1:length(data)
    fprintf('Stream %d: %s | Type: %s | Channels: %s | Sampling Rate: %s Hz\n', ...
        i, data{i}.info.name, data{i}.info.type, ...
        data{i}.info.channel_count, data{i}.info.nominal_srate);
end

%% User Selection of Stream
stream_idx = input('Enter the stream index to inspect (e.g., 1): ');
if stream_idx < 1 || stream_idx > length(data)
    disp('Invalid selection.');
    return;
end

selected_stream = data{stream_idx};

%% Extract Stream Data
time_series = selected_stream.time_series; % Data matrix [channels × samples]
time_stamps = selected_stream.time_stamps; % Time vector [1 × samples]

disp('Stream Data Loaded:');
disp(['Size of time_series: ', mat2str(size(time_series))]);

%% Save the Data for Further Analysis
save_filename = fullfile(path, [selected_stream.info.name, '_data.mat']);
save(save_filename, 'time_series', 'time_stamps', 'selected_stream');
disp(['Saved extracted data to: ', save_filename]);

%% Visualize the First Few Channels
num_channels = min(5, size(time_series, 1)); % Show up to 5 channels
figure;
hold on;
for ch = 1:num_channels
    plot(time_stamps, time_series(ch, :), 'DisplayName', ['Ch' num2str(ch)]);
end
hold off;
legend();
xlabel('Time (s)');
ylabel('Amplitude');
title(['Stream: ', selected_stream.info.name]);
grid on;
disp('Plot displayed.');

