function visualize_DAQ()
    order_index = 3;
    duration = 540;

    % Check if 'data_xdf' exists in the workspace
    if ~evalin('base', 'exist(''data_xdf'', ''var'')')
        error('Variable ''data_xdf'' not found in the workspace.');
    end

    % Retrieve the data from the workspace
    data_xdf = evalin('base', 'data_xdf');

    % Extract the time_series field
    if ~isfield(data_xdf{1,order_index}, 'time_series')
        error('Field ''time_series'' does not exist in data_xdf{1,3}.');
    end

    time_series = data_xdf{1,order_index}.time_series;

    % Validate that time_series is a 2D matrix
    if ~ismatrix(time_series)
        error('time_series must be a 2D matrix.');
    end

    % Get matrix dimensions
    [num_channels, num_samples] = size(time_series);

    % Sampling frequency (Hz)
    Fs = 10000;

    % Number of samples to display
    max_samples = Fs * duration;

    if num_samples > max_samples
        time_series = time_series(:, 1:max_samples);
        num_samples = max_samples;
    end

    % Create time vector
    time_vector = (0:num_samples-1) / Fs;

    % Plot each channel in its own subplot
    figure;
    for i = 1:num_channels
        subplot(num_channels, 1, i);
        plot(time_vector, time_series(i, :));
        ylim([-1, 1]);
        ylabel(sprintf('Ch %d', i));
        if i == 1
            title('DAQ Signal Visualization');
        end
        if i == num_channels
            xlabel('Time (s)');
        end
        grid on;
    end
end