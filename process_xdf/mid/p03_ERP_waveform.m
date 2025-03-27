%% Define settings
channel_labels = {'Fz', 'Cz', 'POz', 'Pz'};
channel_indices = [11, 6, 81, 62];  % Adjust 'EEG.ref' to actual Cz channel index if different
epoch_types = {'cue_reward', 'cue_neutral', 'cue_loss'};
colors = lines(numel(epoch_types));

% Extract time vector
times = EEG.times;

% Initialize structure to hold averages
grand_averages = struct();

%% Loop over cue conditions
for c = 1:length(epoch_types)
    type = epoch_types{c};

    % Find epochs of this type
    selected_epochs = [];
    for i = 1:length(EEG.epoch)
        if isfield(EEG.epoch(i), 'eventtype') && ...
                (iscell(EEG.epoch(i).eventtype) && any(strcmp(EEG.epoch(i).eventtype, type)) || ...
                 ischar(EEG.epoch(i).eventtype) && strcmp(EEG.epoch(i).eventtype, type))
            selected_epochs(end+1) = i;
        end
    end

    if isempty(selected_epochs)
        warning('No epochs found for %s', type);
        continue;
    end

    % Extract data for selected epochs and selected channels
    data = EEG.data(channel_indices, :, selected_epochs);  % [channels x time x trials]

    % Baseline correction (−200 to 0 ms)
    baseline_window = [-200 0];
    [~, b_start] = min(abs(times - baseline_window(1)));
    [~, b_end] = min(abs(times - baseline_window(2)));
    baseline = mean(data(:, b_start:b_end, :), 2);  % mean across time

    data = data - baseline;

    % Average across trials
    avg_waveform = mean(data, 3);  % [channels x time]

    grand_averages.(type) = avg_waveform;
end

%% Plotting
figure;
hold on;
for i = 1:length(channel_labels)
    subplot(1, length(channel_indices), i); hold on;
    for c = 1:length(epoch_types)
        type = epoch_types{c};
        if isfield(grand_averages, type)
            plot(times, grand_averages.(type)(i, :), 'DisplayName', type, 'LineWidth', 1.5, 'Color', colors(c, :));
        end
    end
    title(sprintf('Grand Avg - %s', channel_labels{i}));
    xlabel('Time (ms)');
    ylabel('Amplitude (µV)');
    legend('show');
    yline(0, '--k');
    xline(0, '--k');
    grid on;
end
sgtitle('Stimulus-Locked Grand Average ERPs (Cue Onset)');