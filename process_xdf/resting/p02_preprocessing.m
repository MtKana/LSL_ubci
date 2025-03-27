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

% Notch filter at 50 Hz 
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

%% 7. Downsampling
% % Downsample to 250 Hz for computational efficiency
srate_eeg = 250;
EEG = pop_resample(EEG, srate_eeg);

%% Reject bad channels based on mean amplitude
mean_amplitudes = mean(EEG.data, 2);  % mean across time, for each channel
% bad_channels = find(mean_amplitudes < -100 | mean_amplitudes > 100);
amp_limit = 1400;  % µV
bad_channels = find(any(EEG.data > amp_limit | EEG.data < -amp_limit, 2));
if ~isempty(bad_channels)
    fprintf('Rejecting %d channels', length(bad_channels));
    disp(bad_channels');
    % Create a list of channels to keep
    all_channels = 1:EEG.nbchan;
    good_channels = setdiff(all_channels, bad_channels);
    
    % Keep only the good channels
    EEG = pop_select(EEG, 'channel', good_channels);
end

% Reject extreme amplitudes across any channel (e.g., ±1000 µV)
EEG = pop_eegthresh(EEG, 1, 1:EEG.nbchan, -1000, 1000, EEG.xmin, EEG.xmax, 0, 0);

%% 8. Epoching the data
daq_events = data_xdf{1, order_index_daq}.time_series;
srate_eeg = 250;  
srate_daq = 10000;
ds_factor = srate_daq / srate_eeg; % Calculate downsampling factor

% Downsample DAQ event signals
daq_events_ds = daq_events(:, 1:ds_factor:end);  % crude but effective since it's just digital triggers

event_list = {};
event_types = {'close_1', 'open_1', 'close_2', 'open_2'};

for ch = 1:4
    signal = daq_events_ds(ch, :);
    threshold = 0.8;
    onsets = find(signal(1:end-1) <= threshold & signal(2:end) > threshold);
    for i = 1:length(onsets)
        event_list{end+1} = struct( ...
            'type', event_types{ch}, ...
            'latency', onsets(i)); %#ok<SAGROW>
    end
end

EEG.event = struct('type', {}, 'latency', {});
EEG.event = [event_list{:}];

% Define epoch time window in seconds [start, end]
epoch_time_window = [0 60]; 

%% 
% Extract epochs
EEG = pop_epoch(EEG, event_types, epoch_time_window, 'newname', 'Epoched Data', 'epochinfo', 'yes');

%% Save the processed dataset
EEG = pop_saveset(EEG, 'filename', 'data/JIN_rest_2_preprocessed.set');

% Update EEGLAB GUI
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
eeglab redraw;