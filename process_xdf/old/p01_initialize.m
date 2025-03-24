%% Specify data to analyze

sub = '00';
block = '00';

%% Set PSD and ERSP

path_data = sprintf('data/sub-%s/02_preprocessed_eeg/preprocessed_eeg_block%s.mat', sub, block);

addpath(genpath('./toolbox_iwama'));
data_eeg = load(path_data);

close all;
hep = HelperEEGProcess;
hev = HelperEEGVisualize;

% parameters_analysis;
COI = 36;
range_rest = 1:50;
range_task = 60:260;
clear data_psd
clear data_ERSP
if ~exist('data_psd','var')
    data_psd = hep.fft_eeg(data_eeg.data_eeg_run, 200);
end

if ~exist('data_ERSP','var')
    data_ERSP = hep.calc_ERSP(data_psd,range_rest);
end