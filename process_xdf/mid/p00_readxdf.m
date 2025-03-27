%% readxdf
clearvars
file_xdf = dir('data/JIN_MID_2.xdf');

file_xdf = fullfile(file_xdf(end).folder,file_xdf.name);
data_xdf = load_xdf(file_xdf);

order = xdf_order(data_xdf);

%% daq
% daq = data_xdf{1,order(1)};

%% eeg
% eeg = data_xdf{1,order(2)};

%% keyboard
% keyboard = data_xdf{1,order(3)};

%% tobii (2:left x, 3:left y, 5:right x, 6:right y)
% tobii = data_xdf{1,order(4)};
% x = tobii.time_series(2,:) * 1600;
% 
% % x = sum([tobii.time_series(2,:), tobii.time_series(5,:)], 1, 'omitnan') / 2 * 1600;
% y = sum([tobii.time_series(3,:), tobii.time_series(6,:)], 1, 'omitnan') / 2 * 900;
% 
% % x = tobii.time_series(2,:) * 1600;
% % y = tobii.time_series(3,:) * 900;
% f = figure('Position',[500 100 800 600]);
% hold on
% for i = 1 : 1000
%     plot(x(1,100*i:100*(i+1)), y(1,100*i:100*(i+1)))
%     pause(0.01)
% end

%% audio
% audio = data_xdf{1,order(5)};
% plot(audio.time_series)