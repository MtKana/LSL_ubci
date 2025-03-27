%% Define parameters
Fz_idx = 11;
Cz_idx = 6;  
POz_idx = 81;
Pz_idx = 62;

% Time windows (in ms)
N200_window = [300 400];
P300_window = [300 600];

% Find time indices
[~, n200_start] = min(abs(EEG.times - N200_window(1)));
[~, n200_end]   = min(abs(EEG.times - N200_window(2)));

[~, p300_start] = min(abs(EEG.times - P300_window(1)));
[~, p300_end]   = min(abs(EEG.times - P300_window(2)));

% Epoch types to analyze
epoch_types = {'cue_reward', 'cue_neutral', 'cue_loss'};

% Initialize result struct
erp_results = struct();

%% Loop over conditions
for c = 1:length(epoch_types)
    type = epoch_types{c};

    % Find relevant epochs
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

    % Extract data for selected epochs
    data = EEG.data(:, :, selected_epochs);  % [channels x time x trials]

    % Baseline correction (−200 to 0 ms)
    baseline_window = [-200 0];
    [~, b_start] = min(abs(EEG.times - baseline_window(1)));
    [~, b_end] = min(abs(EEG.times - baseline_window(2)));
    baseline = mean(data(:, b_start:b_end, :), 2);
    data = data - baseline;

    % Average across trials
    avg_data = mean(data, 3);  % [channels x time]

    % Compute N200 (Fz, Cz)
    n200_Fz = mean(avg_data(Fz_idx, n200_start:n200_end));
    n200_Cz = mean(avg_data(Cz_idx, n200_start:n200_end));
    N200 = mean([n200_Fz, n200_Cz]);

    % Compute P300 (Pz, POz)
    p300_Pz = mean(avg_data(Pz_idx, p300_start:p300_end));
    p300_POz = mean(avg_data(POz_idx, p300_start:p300_end));
    P300 = mean([p300_Pz, p300_POz]);

    % Store results
    erp_results.(type).N200 = N200;
    erp_results.(type).P300 = P300;
end

%% Convert erp_results struct to table for display
conditions = fieldnames(erp_results);
N200_vals = [];
P300_vals = [];

for i = 1:length(conditions)
    N200_vals(end+1) = erp_results.(conditions{i}).N200;
    P300_vals(end+1) = erp_results.(conditions{i}).P300;
end

% Plot table in a UI figure
% Create table
erp_table = table(conditions, N200_vals', P300_vals', ...
    'VariableNames', {'Condition', 'N200 (µV)', 'P300 (µV)'});

% Plot table in a UI figure
f = figure('Name', 'ERP Component Summary', 'Position', [100 100 400 200]);
uitable(f, 'Data', table2cell(erp_table), ...
           'ColumnName', erp_table.Properties.VariableNames, ...
           'RowName', [], ...
           'Units', 'Normalized', ...
           'Position', [0 0 1 1]);