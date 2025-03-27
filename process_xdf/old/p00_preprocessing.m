%% Specify data to analyze

sub = '00';
block = '00';

%% Get the raw data

searchDir = sprintf('data/sub-%s/01_ExpResult_EEG', sub);

% Create the search pattern
searchPattern = fullfile(searchDir, sprintf('Block%s*', block));

% Get the list of files matching the search pattern
fileList = dir(searchPattern);

% Check the number of files found
numFiles = length(fileList);

if numFiles == 1
    % If exactly one file is found, load the file path into file_path variable
    [~, fileName, ~] = fileparts(fileList(1).name); % Extract the filename without extension
    fileName = [fileName, 'mff']; % Add 'mff' to the filename
    file_path = fullfile(searchDir, fileList(1).name);
    fprintf('File found: %s\n', file_path);

    % Dynamically create the variable and load the data
    EEG_data = load(file_path); % Assuming you want to load the .mat file
    load(file_path);

    % Replace the placeholder with the actual filename
    assignin('base', 'EEG_data', EEG_data.(fileName));

elseif numFiles > 1l
    % If more than one file is found, throw an error
    error('Multiple files found starting with "Block%s". Please ensure only one file matches the pattern.', block);
else
    % If no files are found, notify the user
    error('No files found starting with "Block%s" in the directory.\n', block);
end

%% Function for visualization

function visualize_eeg(data, fs, title_str)
    time = (0:size(data, 1) - 1) / fs;
    figure;
    % plot(time, data(:, 1:min(10, size(data, 2)))); % Plot the first 10 channels
    plot(time, data(:, [36,104])); % Plot the 36th and 104 channel (C3 and C4)
    title(title_str);
    xlabel('Time (s)');
    ylabel('Amplitude (uV)');
end

%% Set parameters

% Parameters
fs = 1000; 
Fs_downsample = 200;
bandpass_range = [3 45]; % Bandpass filter range
notch_freq = 50; % Notch filter frequency
foi = [8 13; 14 30]; % Frequency of interest (alpha and beta bands)

% Extract EEG data and event timestamps
EEG_data = EEG_data';
EEG_data = EEG_data(1:size(EEG_data, 1) - fs, :); % Delete the last one second of data because those are just zero
event_timestamps = evt_255_DINs;

visualize_eeg(EEG_data, fs, 'raw EEG data');

%% 1. Bandpass filter

[b_bp, a_bp] = butter(2, bandpass_range/(fs/2), 'bandpass');
EEG_data_bp = filtfilt(b_bp, a_bp, EEG_data);
visualize_eeg(EEG_data_bp, fs, 'Bandpass Filtered EEG');

%% 2. Notch filter

[d, c] = butter(2, [(notch_freq-1)/(fs/2), (notch_freq+1)/(fs/2)], 'stop');
EEG_data_notch = filtfilt(d, c, EEG_data_bp);
visualize_eeg(EEG_data_notch, fs, 'Notch Filtered EEG');

%% 3. Split the data into trials
% Extracting task phase durations from event timestamps
event_type = event_timestamps(1, :);
event_time = event_timestamps(2, :);
DIN2_idx = find(strcmp(event_type, 'DIN2'));
DIN5_idx = find(strcmp(event_type, 'DIN5'));
sample_trl = 26*fs;
% Extract data
task_phases = cell(length(DIN2_idx), 1);
for i = 1:length(DIN2_idx)
    start_idx = event_time{DIN2_idx(i)};
    end_idx = event_time{DIN5_idx(i)};
    % task_phases{i} = EEG_data_laplacian(start_idx:end_idx, :);
    task_phases{i} = EEG_data_notch(start_idx+1:start_idx+sample_trl, :);
end

%% 4. Format the data into [time x electrodes x number of trials]

num_trials = length(task_phases);
trial_length = min(cellfun(@(x) size(x, 1), task_phases));
formatted_data = zeros(trial_length, size(EEG_data_notch, 2), num_trials);
for i = 1:num_trials
    formatted_data(:, :, i) = task_phases{i}(1:trial_length, :);
end

% Visualize the formatted data for the first trial
visualize_eeg(formatted_data(:, :, 1), fs, 'Formatted EEG Data (First Trial)');
visualize_eeg(formatted_data(:, :, 2), fs, 'Formatted EEG Data (Second Trial)');

%% 5. Common average reference

% Get the size of the data
[timepoints, channels, trials] = size(formatted_data);
      
% Subtract the average signal from each channel
avg_signal = mean(formatted_data, 2);  
formatted_data_car = formatted_data - avg_signal;

% Visualize the common average referenced data for the first trial
visualize_eeg(formatted_data_car(:, :, 1), fs, 'Common Average Referenced EEG (First Trial)');
visualize_eeg(formatted_data_car(:, :, 2), fs, 'Common Average Referenced EEG (Second Trial)');

%% 6. Downsample the data to 200Hz

signal_eeg_ds = formatted_data_car(1:fs/Fs_downsample:end,:,:);
visualize_eeg(squeeze(signal_eeg_ds(:, :, 1)), Fs_downsample, 'Downsampled EEG (First Trial)');
visualize_eeg(squeeze(signal_eeg_ds(:, :, 2)), Fs_downsample, 'Downsampled EEG (Second Trial)');

data_eeg_run = signal_eeg_ds;
Fs = Fs_downsample;
data_eeg_run_switched = permute(data_eeg_run, [2, 1, 3]);

save(sprintf('data/sub-%s/02_preprocessed_eeg/preprocessed_eeg_block%s.mat', sub, block), 'data_eeg_run');