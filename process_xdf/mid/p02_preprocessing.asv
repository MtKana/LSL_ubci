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
% Detect all events from all 4 DAQ channels
daq_signal = data_xdf{1, order_index_daq}.time_series;

srate_daq = 10000;
srate_eeg = 250;
ds_factor = srate_daq / srate_eeg;
threshold = 1;

event_candidates = struct('daq_latency', {}, 'channel', {}, 'eeg_latency', {});

for ch = 1:4
    signal = daq_signal(ch, :);
    
    raw_onsets = find(signal(1:end-1) <= threshold & signal(2:end) > threshold);
    raw_onsets = raw_onsets(:);  % ensure column
    
    for i = 1:length(raw_onsets)
        event_candidates(end+1).daq_latency = raw_onsets(i); %#ok<SAGROW>
        event_candidates(end).channel = ch;
        event_candidates(end).eeg_latency = round(raw_onsets(i) / ds_factor);
    end
end

% Sort by EEG latency
[~, sort_idx] = sort([event_candidates.eeg_latency]);
event_candidates = event_candidates(sort_idx);

% Ensure the length of event_candidates is 1224
desired_length = 1224;
current_length = length(event_candidates);

if current_length > desired_length
    event_candidates = event_candidates(1:desired_length);
end

% Rename 'eeg_latency' to 'timepoint' and remove 'daq_latency'
event_candidates = rmfield(event_candidates, 'daq_latency');
[event_candidates.timepoint] = event_candidates.eeg_latency;
event_candidates = rmfield(event_candidates, 'eeg_latency');

%% 
% Fixed event sequence per trial
event_labels = {'rest', 'cue', 'fixation', 'target', 'feedback', 'end'};
events_per_trial = numel(event_labels);

% Check that event count is valid
if mod(numel(event_candidates), events_per_trial) ~= 0
    warning('Event count (%d) is not a multiple of expected events per trial (%d)', ...
        numel(event_candidates), events_per_trial);
end

EEG.event = struct('type', {}, 'latency', {});
trial_types = {};  % Store trial types for cue and feedback

for i = 1:length(event_candidates)
    trial_idx = floor((i - 1) / events_per_trial) + 1;
    event_idx = mod(i - 1, events_per_trial) + 1;
    
    event_name = event_labels{event_idx};
    latency = event_candidates(i).timepoint;
    signal_ch = event_candidates(i).channel;
    
    % Determine trial type for cue and feedback
    if strcmp(event_name, 'cue')
        switch signal_ch
            case 2
                trial_type = 'reward';
            case 1
                trial_type = 'neutral';
            case 3
                trial_type = 'loss';
            otherwise
                trial_type = 'unknown';
        end
        trial_types{trial_idx} = trial_type;
    elseif strcmp(event_name, 'feedback')
        switch signal_ch
            case 4
                trial_type = 'gain';
            case 1
                trial_type = 'loss';
            otherwise
                trial_type = 'unknown';
        end
        % Store feedback trial type separately if you like, or overwrite
        trial_types{trial_idx} = trial_type;
    end

    % Build labeled type
    if strcmp(event_name, 'cue')
        if trial_idx <= length(trial_types)
            labeled_type = [event_name '_' trial_types{trial_idx}];
        else
            labeled_type = event_name;
        end
    elseif strcmp(event_name, 'feedback')
        if trial_idx <= length(trial_types)
            labeled_type = [event_name '_' trial_types{trial_idx}];
        else
            labeled_type = event_name;
        end
    else
        labeled_type = event_name;
    end

    % Add event
    EEG.event(end+1).type = labeled_type;
    EEG.event(end).latency = latency;
end

% Sort EEG events by latency
[~, idx] = sort([EEG.event.latency]);
EEG.event = EEG.event(idx);

%% Epoch only for labeled cue events (with trial types)
epoch_window = [-0.2 1];
epoch_types = {'cue_reward', 'cue_neutral', 'cue_loss', 'feedback_gain', 'feedback_loss'};

EEG = pop_epoch(EEG, epoch_types, epoch_window, 'newname', 'Cue Epochs by Trial Type', 'epochinfo', 'yes');

%% 

% %% Save the processed dataset
EEG = pop_saveset(EEG, 'filename', 'data/JIN_MID_2_preprocessed.set');
% 
% % Update EEGLAB GUI
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
eeglab redraw;