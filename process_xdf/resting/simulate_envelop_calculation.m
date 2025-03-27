% Assuming EEG (from EEGLAB) is already loaded and preprocessed
eeg_data = EEG.data;       % [channels x timepoints]
Fs = EEG.srate;            % sampling rate (should be 250 Hz after downsampling)
chan_labels = {EEG.chanlocs.labels};  % channel labels
time = linspace(0, EEG.pnts / Fs, EEG.pnts);  % time vector

% Select a specific channel for demonstration (e.g., channel Cz)
channel_name = 'Cz';  % Change this to any label you want
channel_index = find(strcmpi(chan_labels, channel_name));
signal = double(eeg_data(channel_index, :));  % Convert to double if not already

% 1. Bandpass filter (8–13 Hz for alpha band)
alphaBand = designfilt('bandpassiir', 'FilterOrder', 4, ...
                       'HalfPowerFrequency1', 8, 'HalfPowerFrequency2', 13, ...
                       'SampleRate', Fs);
alpha_filtered = filtfilt(alphaBand, signal);

% 2. Envelope via Hilbert transform
analytic_signal = hilbert(alpha_filtered);
envelope = abs(analytic_signal);

% 3. Peak envelope (interpolated)
[~,locs] = findpeaks(envelope);
peak_envelope = zeros(size(envelope));
peak_envelope(locs) = envelope(locs);
peak_envelope = interp1(locs, envelope(locs), 1:length(envelope), 'pchip', 'extrap');

% 4. Second derivative of envelope
second_derivative = diff(envelope, 2);
second_derivative = [0 second_derivative 0];  % pad for same length

% 5. Ap, An, Ap/An ratio
Ap = mean(second_derivative(second_derivative > 0));
An = mean(second_derivative(second_derivative < 0));
Ap_An_ratio = Ap / abs(An);

% 6. RMS of alpha-filtered signal
rms_alpha = sqrt(mean(alpha_filtered.^2));

% 7. Plotting
figure;
plot(time, alpha_filtered, 'k', 'DisplayName', 'Alpha Filtered (8–13 Hz)'); hold on;
plot(time, envelope, 'b', 'DisplayName', 'Envelope');
plot(time, peak_envelope, 'r', 'DisplayName', 'Peak Envelope');
xlabel('Time (s)');
ylabel('Amplitude (µV)');
title(['Alpha Activity for Channel ' channel_name]);
legend;

% 8. Table display in a separate figure
metrics = {'Ap (mean +2nd deriv)', 'An (mean -2nd deriv)', ...
           'Ap/An Ratio', 'RMS Alpha Amplitude'}';
values = [Ap; An; Ap_An_ratio; rms_alpha];
tableData = [metrics, num2cell(values)];

figure('Name', ['Alpha Metrics - Channel ' channel_name]);
uitable('Data', tableData, ...
        'ColumnName', {'Metric', 'Value'}, ...
        'RowName', [], ...
        'Units', 'normalized', ...
        'Position', [0 0 1 1]);