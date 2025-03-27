% === ERP Analysis Parameters ===
channel_labels = {'Fz', 'FCz', 'POz', 'Pz'};
channel_indices = [11, 6, 81, 62];
erp_window = [-0.2 1];  % 200ms pre to 1000ms post
baseline_window = [-0.2 0];  % for baseline correction

n200_window = [0.18 0.28];
rewp_window = [0.25 0.35];

% === Extract epochs ===
feedback_gain_epochs = pop_selectevent(EEG, 'type', 'feedback_gain');
feedback_loss_epochs = pop_selectevent(EEG, 'type', 'feedback_loss');

% === Baseline correction ===
feedback_gain_epochs = pop_rmbase(feedback_gain_epochs, [baseline_window(1)*1000 baseline_window(2)*1000]);
feedback_loss_epochs = pop_rmbase(feedback_loss_epochs, [baseline_window(1)*1000 baseline_window(2)*1000]);

% === Calculate ERP (average across trials and selected channels) ===
erp_gain = mean(mean(feedback_gain_epochs.data(channel_indices,:,:), 1), 3);
erp_loss = mean(mean(feedback_loss_epochs.data(channel_indices,:,:), 1), 3);
erp_gain = squeeze(erp_gain);
erp_loss = squeeze(erp_loss);

% === Time vector ===
time_vector = linspace(erp_window(1), erp_window(2), size(feedback_gain_epochs.data, 2)) * 1000; % in ms

% === Plot ERP waveforms ===
figure; hold on;
plot(time_vector, erp_gain, 'b', 'LineWidth', 2);
plot(time_vector, erp_loss, 'r', 'LineWidth', 2);
xlabel('Time (ms)');
ylabel('Amplitude (µV)');
legend({'Feedback Gain', 'Feedback Loss'});
title('ERP Waveform at Feedback Onset (Channels: Fz, FCz, POz, Pz)');
grid on;

% === Draw gray boxes for ERP windows ===
y_limits = ylim;
patch([n200_window fliplr(n200_window)]*1000, [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], ...
    [0.8 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
patch([rewp_window fliplr(rewp_window)]*1000, [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], ...
    [0.5 0.5 0.5], 'EdgeColor', 'none', 'FaceAlpha', 0.3);

% === Compute mean ERP values for topographies and summary ===
get_mean_erp = @(data, t_range) mean(mean(data(:, time_vector >= t_range(1)*1000 & time_vector <= t_range(2)*1000, :), 2), 3);

n200_gain = get_mean_erp(feedback_gain_epochs.data, n200_window);
n200_loss = get_mean_erp(feedback_loss_epochs.data, n200_window);
rewp_gain = get_mean_erp(feedback_gain_epochs.data, rewp_window);
rewp_loss = get_mean_erp(feedback_loss_epochs.data, rewp_window);

% === Plot Topography Maps ===
figure;
subplot(2,2,1); topoplot(n200_gain, EEG.chanlocs); title('N200 - Feedback Gain');
subplot(2,2,2); topoplot(n200_loss, EEG.chanlocs); title('N200 - Feedback Loss');
subplot(2,2,3); topoplot(rewp_gain, EEG.chanlocs); title('RewP - Feedback Gain');
subplot(2,2,4); topoplot(rewp_loss, EEG.chanlocs); title('RewP - Feedback Loss');

% === Create Table Data for uitable ===
table_data = {
    'Feedback Gain', mean(n200_gain(channel_indices)), mean(rewp_gain(channel_indices));
    'Feedback Loss', mean(n200_loss(channel_indices)), mean(rewp_loss(channel_indices));
};

column_names = {'Condition', 'N200 (µV)', 'RewP (µV)'};

% === Create Figure for Table ===
f = figure('Name', 'ERP Summary Table', 'NumberTitle', 'off', 'Position', [100 100 400 150]);

% === Create UI Table ===
uitable(f, ...
    'Data', table_data, ...
    'ColumnName', column_names, ...
    'RowName', [], ...
    'Units', 'Normalized', ...
    'Position', [0 0 1 1]);