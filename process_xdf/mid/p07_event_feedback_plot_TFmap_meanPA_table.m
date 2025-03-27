% === Parameters ===
fz_idx = 11;
bands = {
    'Delta', [1 4];
    'Theta', [4 8];
    'Alpha', [8 13];
    'Beta', [13 30];
    'Gamma', [30 50];
};

% === Extract Fz Data ===
gain_data = squeeze(feedback_gain_epochs.data(fz_idx,:,:));  % time x trials
loss_data = squeeze(feedback_loss_epochs.data(fz_idx,:,:));  % time x trials

% === Time-Frequency Parameters ===
% --- Settings ---
cycles = [1.5 0.5];
freqrange = [3 50];
nfreqs = 60;
tlimits = [EEG.xmin EEG.xmax]*1000;

% --- TFR: Feedback Gain ---
% === Corrected Time-Frequency Computation ===
[power_gain, ~, ~, times, freqs] = newtimef(gain_data, EEG.pnts, tlimits, EEG.srate, ...
    'cycles', cycles, 'freqs', freqrange, 'nfreqs', nfreqs, ...
    'plotersp', 'off', 'plotitc', 'off');

[power_loss, ~, ~, ~, ~] = newtimef(loss_data, EEG.pnts, tlimits, EEG.srate, ...
    'cycles', cycles, 'freqs', freqrange, 'nfreqs', nfreqs, ...
    'plotersp', 'off', 'plotitc', 'off');

% === Also confirm dimensions ===
fprintf('Freq range: %.2f to %.2f Hz\n', min(freqs), max(freqs));
fprintf('Time range: %.2f to %.2f ms\n', min(times), max(times));


% --- Plot TFR Maps ---
figure;
subplot(1,2,1);
imagesc(times, freqs, power_gain); axis xy;
title('TFR - Feedback Gain (Fz)');
xlabel('Time (ms)'); ylabel('Frequency (Hz)'); colorbar;

subplot(1,2,2);
imagesc(times, freqs, power_loss); axis xy;
title('TFR - Feedback Loss (Fz)');
xlabel('Time (ms)'); ylabel('Frequency (Hz)'); colorbar;
% === Calculate Band Powers ===
get_band_power = @(power, freqs, band_range) ...
    mean(power(freqs >= band_range(1) & freqs <= band_range(2), :), 'all');

num_bands = size(bands, 1);
gain_band_vals = zeros(num_bands,1);
loss_band_vals = zeros(num_bands,1);

for i = 1:num_bands
    band_range = bands{i,2};
    gain_band_vals(i) = get_band_power(power_gain, freqs, band_range);
    loss_band_vals(i) = get_band_power(power_loss, freqs, band_range);
end

% === Prepare Table Data ===
table_data = [bands(:,1), num2cell(gain_band_vals), num2cell(loss_band_vals)];
column_names = {'Frequency Band', 'Feedback Gain (dB)', 'Feedback Loss (dB)'};

% === Create Table Figure ===
f = figure('Name', 'Time-Frequency Band Power Summary', 'NumberTitle', 'off', 'Position', [100 100 500 200]);
uitable(f, ...
    'Data', table_data, ...
    'ColumnName', column_names, ...
    'RowName', [], ...
    'Units', 'Normalized', ...
    'Position', [0 0 1 1]);