%% set para
sub = 'A';

i_n = 5;
repeat_n = 5;
trial_n = 1;

Fs = 1000;
bf_dur = 0.1;
bf_span = Fs * bf_dur;

%% initialize
ersp = cell(trial_n,repeat_n);

for trial = 1 : trial_n
    %% read xdf
    file_xdf = ['BMI_',num2str(trial),'.xdf'];
    data_xdf = load_xdf(file_xdf);
    
    %% initialize
    daq = struct;
    eeg = struct;
    LE = class_EGI(Fs);
    
    %% acquire data
    x = xdf_order(data_xdf);  % 1:daq, 2:eeg, 3:keyboard, 4:tobii, 5:audio
    
    daq.time = data_xdf{1,x(1)}.time_stamps(1,:);
    daq.data = data_xdf{1,x(1)}.time_series(:,:);
    
    eeg.time = data_xdf{1,x(2)}.time_stamps(1,:);
    eeg.data = double(data_xdf{1,x(2)}.time_series(:,:)');

    daq.sig_1 = find(daq.data(1,:) > 4);

    for r = 1 : repeat_n
        %% check order time
        for i = 1 : i_n  % 1:blank, 2:rest, 3:ready, 4:task, 5:end
            daq.order_t(1,i) = daq.time(daq.sig_1(1+(i-1)*100+(r-1)*(i_n*100)));
            [~, eeg.order_t(1,i)] = min(abs(eeg.time(1,:) - daq.order_t(1,i)));
        end

        %% calc ref
        eeg.rest_t = round((eeg.order_t(1,3) - eeg.order_t(1,2)) / bf_span);

        for t = 1 : eeg.rest_t
            LE = LE.filtfilt(eeg.data(eeg.order_t(1,2)+bf_span*(t-1)-Fs/2+1:eeg.order_t(1,2)+bf_span*(t-1)+Fs/2,:));
            LE = LE.calc_power();
            LE.result.ref = LE.result.ref + LE.result.out;
        end
        LE.result.ref = LE.result.ref / eeg.rest_t;
        
        %% calc ersp
        eeg.task_t = round((eeg.order_t(1,5) - eeg.order_t(1,2)) / bf_span);
        disp(eeg.task_t)
        ersp{trial,r} = zeros(eeg.task_t,LE.para.frq,128);

        for t = 1 : eeg.task_t
            LE = LE.filtfilt(eeg.data(eeg.order_t(1,2)+bf_span*(t-1)-Fs/2+1:eeg.order_t(1,2)+bf_span*(t-1)+Fs/2,:));
            LE = LE.calc_power();
            ersp{trial,r}(t,:,:) = (LE.result.out - LE.result.ref) ./ LE.result.ref * 100;
        end
    end
end

%% organize data
ERSP = cat(4,ERSP{2:5});

%% save data
filename = ['ERSP_BMI_',sub,'.mat'];
save(filename,"ERSP")