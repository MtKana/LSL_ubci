%% Parameters
channel_labels = {'Fz', 'FCz', 'POz', 'Pz'};
channel_indices = [11, 6, 81, 62];
epoch_types = {'cue_reward', 'cue_neutral', 'cue_loss'};
colors = lines(3);

% Time windows (ms)
erp_windows = struct( ...
    'N200', [300 400], ...
    'P300', [300 600], ...
    'CNV',  [500 1000] ...
);

baseline_window = [-200 0]; % ms

%% Prepare time indices
[~, base_start] = min(abs(EEG.times - baseline_window(1)));
[~, base_end]   = min(abs(EEG.times - baseline_window(2)));

erp_indices = struct();
fields = fieldnames(erp_windows);
for i = 1:length(fields)
    win = erp_windows.(fields{i});
    [~, start_idx] = min(abs(EEG.times - win(1)));
    [~, end_idx]   = min(abs(EEG.times - win(2)));
    erp_indices.(fields{i}) = [start_idx, end_idx];
end

%% Initialize storage
avg_waveforms = struct();
topo_data = struct();

%% Loop over conditions
for c = 1:length(epoch_types)
    type = epoch_types{c};

    % Get trial indices
    trial_idx = find(arrayfun(@(e) any(strcmp(e.eventtype, type)), EEG.epoch));

    % Extract data and baseline-correct
    data = EEG.data(:, :, trial_idx);
    baseline = mean(data(:, base_start:base_end, :), 2);
    data = data - baseline;

    % Average waveform at selected channels
    avg_waveforms.(type) = squeeze(mean(data(channel_indices, :, :), 3)); % [channels x time]

    % Topographic maps for ERP windows
    topo_data.(type) = struct();
    for f = 1:length(fields)
        field = fields{f};
        idx = erp_indices.(field);
        topo_avg = mean(mean(data(:, idx(1):idx(2), :), 2), 3); % mean over time and trials
        topo_data.(type).(field) = topo_avg;
    end
end

%% === Plot ERP waveforms ===
figure('Name','ERP + Topography','Position',[100 100 1400 600]);

subplot(1,2,1); hold on;
for c = 1:length(epoch_types)
    type = epoch_types{c};
    avg = mean(avg_waveforms.(type), 1); % average across selected channels
    plot(EEG.times, avg, 'LineWidth', 1.8, 'Color', colors(c,:), 'DisplayName', type);
end

% Add shaded boxes for ERP windows
yl = ylim;
for i = 1:length(fields)
    win = erp_windows.(fields{i});
    fill([win(1) win(2) win(2) win(1)], [yl(1) yl(1) yl(2) yl(2)], ...
        [0.6 0.6 0.6], 'FaceAlpha', 0.2, 'EdgeColor', 'none');
end

xlabel('Time (ms)');
ylabel('Amplitude (µV)');
title('ERP Waveforms at Selected Channels');
legend('show');
grid on;
xline(0, '--k'); % cue onset line

%% === Plot Topographies ===
erp_components = fields; % {'N200', 'P300', 'CNV'}
n_rows = length(epoch_types);
n_cols = length(erp_components);

for row = 1:n_rows
    for col = 1:n_cols
        type = epoch_types{row};
        comp = erp_components{col};
        subplot_idx = col + (row-1)*n_cols;
        subplot(n_rows, n_cols, subplot_idx);
        topoplot(topo_data.(type).(comp), EEG.chanlocs, 'maplimits', 'absmax', 'electrodes', 'off');
        title(sprintf('%s - %s', strrep(type,'_','\_'), comp));
    end
end

%% === Build ERP summary table ===
erp_types = {'N200', 'P300', 'CNV'};
all_conditions = epoch_types;

rows = {};
n200_vals = [];
p300_vals = [];
cnv_vals = [];

for i = 1:length(all_conditions)
    cond = all_conditions{i};
    n200_vals(end+1) = mean(topo_data.(cond).N200);  % mean across all electrodes
    p300_vals(end+1) = mean(topo_data.(cond).P300);
    cnv_vals(end+1)  = mean(topo_data.(cond).CNV);
    rows{end+1} = cond;
end

% Create the table
erp_table = table(rows', n200_vals', p300_vals', cnv_vals', ...
    'VariableNames', {'Condition', 'N200 (µV)', 'P300 (µV)', 'CNV (µV)'});

%% === Display ERP table in a separate UI window ===
f = figure('Name', 'ERP Summary Table', 'Position', [100 100 500 200]);
uitable(f, ...
    'Data', table2cell(erp_table), ...
    'ColumnName', erp_table.Properties.VariableNames, ...
    'RowName', [], ...
    'Units', 'Normalized', ...
    'Position', [0 0 1 1]);
