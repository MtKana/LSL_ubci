%% Initialize EEGLAB
path_eeglab = '/Applications/eeglab2024.1';
addpath(path_eeglab);
eeglab;

%% Load raw EEG data

eeg_data = data_xdf{1, order_index_eeg}.time_series;  % 128 x timepoints
srate_eeg = 1000;

EEG = pop_importdata( 'dataformat', 'array', 'data', eeg_data, 'nbchan', 128, 'srate', srate_eeg);
chanlocs_file = '/Applications/eeglab2024.1/sample_locs/AdultAverageNet128_v1.sfp';
chanlocs = readlocs(chanlocs_file, 'filetype', 'sfp');
chanlocs_clean = chanlocs(4:131);
EEG.chanlocs = chanlocs_clean;

%% 1. Re-referencing
% Re-reference to common average
EEG = pop_reref(EEG, []);

% Alternatively, re-reference to linked mastoids (e.g., channels 129 and 130 for A1 and A2)
% Ensure that the mastoid channels are included in your data
% EEG = pop_reref(EEG, [129 130]);

%% 2. Filtering
% Bandpass filter from 0.1 to 40 Hz
EEG = pop_eegfiltnew(EEG, 0.1, 40);

%% Notch filter at 50 Hz (adjust to 60 Hz if necessary)
EEG = pop_eegfiltnew(EEG, 49, 51, [], 1);

%% 3. Artifact rejection via ICA
% Run ICA
% EEG = pop_runica(EEG, 'extended', 1);

%% Inspect and remove components associated with ocular, muscular, and cardiac artifacts

% Via automated tools like ICLabel
% EEG = pop_iclabel(EEG, 'default');
% EEG = pop_icflag(EEG, [NaN NaN; 0.8 1; 0.8 1; 0.8 1; 0.8 1; 0.8 1; NaN NaN]);
% EEG = pop_subcomp(EEG);

% Via manual inspection
% pop_selectcomps(EEG, 33:128); % View first 32 components

%% 5. Baseline correction
% % Perform baseline correction using the pre-stimulus interval (-200 ms to 0 ms)
% EEG = pop_rmbase(EEG, [-200 0]);

%% 6. Epoch rejection for residual high-amplitude artifacts
% % Reject epochs with any channel exceeding ±100 µV
% EEG = pop_eegthresh(EEG, 1, 1:EEG.nbchan, -100, 100, EEG.xmin, EEG.xmax, 0, 1);
% 
%% 7. Downsampling
% % Downsample to 250 Hz for computational efficiency
EEG = pop_resample(EEG, 250);

%% 8. Epoching the data
daq_signal = data_xdf{1, order_index_daq}.time_series;

srate_daq = 10000;  % DAQ sampling rate
ds_factor = srate_daq / srate_eeg;

threshold = 1;
onsets_raw = find(daq_signal(1:end-1) <= threshold & daq_signal(2:end) > threshold);

% Convert to column vector, just in case
onsets_raw = onsets_raw(:);

% Set your minimum interval (in samples)
min_interval_samples = round(0.015 * srate_daq);  % Adjust this for your experiment

% Filter out detections that are too close together
onsets_daq = onsets_raw([true; diff(onsets_raw) > min_interval_samples]);
% Convert DAQ latencies to EEG sample points
onsets_eeg = round(onsets_daq / ds_factor);

% Define fixed event order per trial
trial_event_types = {'rest', 'cue', 'fixation', 'target', 'feedback', 'end'};
events_per_trial = numel(trial_event_types);

% Validate event count
% if mod(numel(onsets_eeg), events_per_trial) ~= 0
%     warning('Detected events (%d) not divisible by %d (events per trial)', ...
%         numel(onsets_eeg), events_per_trial);
% end

% Create EEGLAB-style event structure
% event_list = struct('type', {}, 'latency', {});
% for i = 1:length(onsets_eeg)
%     trial_pos = mod(i-1, events_per_trial) + 1;
%     event_list(end+1).type = trial_event_types{trial_pos};
%     event_list(end).latency = onsets_eeg(i); % EEG sample index
% end

% Sort events by latency (safety step)
% [~, idx] = sort([event_list.latency]);
% event_list = event_list(idx);
% 
% % Assign to EEG
% EEG.event = event_list;

% Epoch the EEG data
epoch_window = [-0.2 0.8]; % in seconds

%% 
% Extract epochs
% EEG = pop_epoch(EEG, event_types, epoch_time_window, 'newname', 'Epoched Data', 'epochinfo', 'yes');
% 
% %% Save the processed dataset
% EEG = pop_saveset(EEG, 'filename', 'data/JIN_rest_2_preprocessed.set');
% 
% % Update EEGLAB GUI
% [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
% eeglab redraw;