addpath('../toolbox_iwama')
path_data = '~/Dropbox/data_tmp/testdata_esi';
file_data = dir(fullfile(path_data,'*.mat'));
file_data = Atom.fullPath(file_data);
data_eeg  = cellfun(@load,file_data,'uniformoutput',false);
name_field= cellfun(@fieldnames,data_eeg,'UniformOutput',false);
name_field= [name_field{:}];
%% preproc
hep = HelperEEGPreprocess;
hev = HelperEEGVisualize;
num_run = numel(data_eeg);
data_eeg_run = cell(num_run,1);
data_imp_run = cell(num_run,1);
for i_run = 1 : num_run
    [data_eeg_run{i_run},data_imp_run{i_run}] = hep.preprocess(data_eeg{i_run});
end
data_eeg_run = cat(3,data_eeg_run{:});
data_imp_run = [data_imp_run{:}];
%% find bad ch
threshold_imp = 50;
ch_bad = hep.find_bad_ch(data_imp_run,threshold_imp,'any');
%% visualize_quality_check
COI = 36;
Fs = 1000;
close all
hev.check_eeg_raw(data_eeg_run,COI,Fs);
idx_trl_reject = [];
%% downsampling
Fs_ds = 200;
data_eeg_run = data_eeg_run(1:Fs/Fs_ds:end,:,:);
Fs = Fs_ds;
%% save dataset
list_var = {'data_eeg_run','data_imp_run','Fs','threshold_imp','ch_bad'};
save('dataset_eeg',list_var{:});


