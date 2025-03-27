% Define frequency bands
freq_bands = {
    'Delta',     [1 4];
    'Theta',     [4 8];
    'Alpha',     [8 13];
    'Beta',      [13 30];
    'High_Beta', [20 30];
    'Gamma',     [30 80]
};

% Define channel groups corresponding to brain regions
channel_groups = {
    'Entire',    1:EEG.nbchan;
    'Frontal',   1:32;
    'Central',   33:64;
    'Posterior', 65:96
};

% Initialize structure to store power values
absolute_power = struct();

% Compute power spectral density (PSD) using spectopo
[psd_data, freqs] = spectopo(reshape(EEG.data, EEG.nbchan, []), 0, EEG.srate, 'plot', 'off');

% Convert PSD from dB to linear scale
psd_linear = 10.^(psd_data / 10);

% Loop over each frequency band
for fb = 1:size(freq_bands, 1)
    band_name = freq_bands{fb, 1};
    band_range = freq_bands{fb, 2};
    
    % Find indices corresponding to the current frequency band
    band_indices = find(freqs >= band_range(1) & freqs <= band_range(2));
    
    % Loop over each channel group (brain region)
    for cg = 1:size(channel_groups, 1)
        region_name = channel_groups{cg, 1};
        channels = channel_groups{cg, 2};
        
        % Calculate absolute power by averaging the PSD values within the band and across channels
        abs_power = mean(mean(psd_linear(channels, band_indices), 2));
        
        % Store absolute power
        absolute_power.(band_name).(region_name) = abs_power;
    end
end

% Calculate power ratios
power_ratios = struct();
for cg = 1:size(channel_groups, 1)
    region_name = channel_groups{cg, 1};
    
    delta_power = absolute_power.Delta.(region_name);
    alpha_power = absolute_power.Alpha.(region_name);
    theta_power = absolute_power.Theta.(region_name);
    beta_power = absolute_power.Beta.(region_name);
    
    % Compute Delta/Alpha ratio
    delta_alpha_ratio = delta_power / alpha_power;
    power_ratios.(region_name).Delta_Alpha = delta_alpha_ratio;
    
    % Compute Theta/Beta ratio
    theta_beta_ratio = theta_power / beta_power;
    power_ratios.(region_name).Theta_Beta = theta_beta_ratio;
end

% Initialize cell array to store table data
table_data = cell(32, 3);
row_idx = 1;

% Populate table with absolute power values
for fb = 1:size(freq_bands, 1)
    band_name = freq_bands{fb, 1};
    for cg = 1:size(channel_groups, 1)
        region_name = channel_groups{cg, 1};
        power_value = absolute_power.(band_name).(region_name);
        table_data{row_idx, 1} = band_name;
        table_data{row_idx, 2} = region_name;
        table_data{row_idx, 3} = power_value;
        row_idx = row_idx + 1;
    end
end

% Populate table with power ratio values
ratio_names = {'Delta/Alpha', 'Theta/Beta'};
for r = 1:length(ratio_names)
    ratio_name = ratio_names{r};
    for cg = 1:size(channel_groups, 1)
        region_name = channel_groups{cg, 1};
        power_value = power_ratios.(region_name).(strrep(ratio_name, '/', '_'));
        table_data{row_idx, 1} = ratio_name;
        table_data{row_idx, 2} = region_name;
        table_data{row_idx, 3} = power_value;
        row_idx = row_idx + 1;
    end
end

% Convert cell array to table
result_table = cell2table(table_data, 'VariableNames', {'Frequency_Band', 'Brain_Region', 'Power_Value'});


% Convert numeric values to strings rounded to 3 decimal places
formatted_data = table2cell(result_table);
for i = 1:size(formatted_data, 1)
    if isnumeric(formatted_data{i, 3})
        formatted_data{i, 3} = sprintf('%.3f', formatted_data{i, 3});
    end
end

% Create a new figure for the table
f = figure('Name', 'EEG Power Summary Table', 'NumberTitle', 'off', ...
           'Color', 'w', 'Position', [100, 100, 800, 700]);

% Create a uitable and populate it with formatted data
t = uitable(f, ...
            'Data', formatted_data, ...
            'ColumnName', result_table.Properties.VariableNames, ...
            'Units', 'Normalized', ...
            'Position', [0, 0, 1, 1], ...
            'FontSize', 12);