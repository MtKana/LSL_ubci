function visualizeDAQSignal()
    % Check if 'data_xdf' exists in the workspace
    if ~evalin('base', 'exist(''data_xdf'', ''var'')')
        error('Variable ''data_xdf'' not found in the workspace.');
    end
    
    % Retrieve the data from the workspace
    data_xdf = evalin('base', 'data_xdf');
    
    % Check if the specified index exists in the cell array
    if size(data_xdf,1) < 1 || size(data_xdf,2) < 3
        error('data_xdf{1,3} does not exist.');
    end
    
    % Extract the time_series field
    if ~isfield(data_xdf{1,3}, 'time_series')
        error('Field ''time_series'' does not exist in data_xdf{1,3}.');
    end
    
    time_series = data_xdf{1,3}.time_series;
    
    % Validate that time_series is a 2D matrix
    if ~ismatrix(time_series)
        error('time_series must be a 2D matrix.');
    end
    
    % Get matrix dimensions
    [num_channels, num_samples] = size(time_series);
    
    % Sampling frequency (Hz)
    Fs = 10000;
    
    % Duration to visualize (seconds)
    duration = 60;
    
    % Number of samples to display
    max_samples = Fs * duration;
    
    % Limit the data to the first 60 seconds
    if num_samples > max_samples
        time_series = time_series(:, 1:max_samples);
        num_samples = max_samples;
    end
    
    % Create time vector
    time_vector = (0:num_samples-1) / Fs; % Convert sample indices to time
    
    % Plot each row (channel) as a separate signal
    figure;
    hold on;
    for i = 1:num_channels
        plot(time_vector, time_series(i, :), 'DisplayName', sprintf('Channel %d', i));
    end
    hold off;
    
    xlabel('Time (s)');
    ylabel('Amplitude');
    title('DAQ Signal Visualization (First 60 sec)');
    legend;
    grid on;
end
