p01_initialize;
%% process
idx_qc = input('Which QC will you use? 1:raw wave, 2:psd, 3:TF, 4:Topo->');
close all
if idx_qc == 1
    %% qc signal
    hev.check_eeg_raw(data_eeg.data_eeg_run,COI,data_eeg.Fs);
elseif idx_qc == 2
    %% qc psd
    figure;
    hev.check_psd(data_psd(range_rest,:,COI,:),1);
    hold on;
    hev.check_psd(data_psd(range_task,:,COI,:),2);
    legend({'rest';'task'})
elseif idx_qc == 3
    %% tf
    hev.check_tf(data_ERSP(:,:,COI,[1,2,4:end]),100);
elseif idx_qc == 4
    %% topo
    range_task = 60:260;
    FOI = 14:30;
    list_ch = [1 : size(data_ERSP,3)]';
    % list_ch(data_eeg.ch_bad) = [];
    figure;
    hev.check_topo(data_ERSP(range_task,FOI,list_ch,:),list_ch,50);
else
    fprintf('Not implemented\n');
end

