classdef HelperEEGPreprocess
    methods (Static)

        function [out_eeg,out_imp] = preprocess(in,time)
            hep = HelperEEGPreprocess;
            if nargin < 2
                time = [6,5]; % test data
            end

            % set parameters
            name_imp = 'Impedances_EEG_0';
            Fs = in.('EEGSamplingRate');
            name_field = fieldnames(in);

            % get eeg data
            signal_eeg = double(in.(name_field{1}))';
            signal_eeg = hep.filter_eeg_default(signal_eeg,Fs);
            num_ch = size(signal_eeg,2);

            % get impedance data
            if any(contains(name_field,name_imp))
                out_imp = in.(name_imp);
            else
                out_imp = NaN(num_ch,1);
            end

            % instant epoching
            % get din data
            data_din = in.(name_field{end});
            [type_din,time_din] = hep.get_din_info(data_din);
            
            % find epoch marker
            is_motor_exec = @(x) (contains(x,'2')|contains(x,'3')|contains(x,'4'));
            idx_task = find(arrayfun(is_motor_exec,type_din));
            % count trials
            num_trl = numel(idx_task);
            out_eeg = zeros(sum(time)*Fs,num_ch,num_trl);
            for i_trl = 1 : num_trl
                time_task = time_din(idx_task(i_trl));
                range_time = time_task-time(1)*Fs+1:time_task+time(2)*Fs;
                out_eeg(:,:,i_trl) = signal_eeg(range_time,:);
            end

        end

        function out = filter_eeg_default(in,Fs)
            % set filter para
            notch = 50;
            [bpb,bpa] = butter(3,[3 70]/(Fs/2));
            [ncb,nca] = butter(3,[notch-1 notch+1]/(Fs/2),"stop");
            out = filtfilt(ncb,nca,filtfilt(bpb,bpa,in));
        end

        function [type_din,time_din] = get_din_info(data_din)
            type_din = reshape([data_din{1,:}],4,[]);
            type_din = type_din(end,:);
            time_din = [data_din{2,:}]';
        end
    end

    methods (Static)

        function ch_bad = find_bad_ch(data_imp,threshold,type)
            arguments
                data_imp = [];
                threshold = 50;
                type = 'any';                
            end

            is_up_th = data_imp > threshold;
            switch type
                case 'any'
                    ch_bad = find(any(is_up_th,2));
                case 'all'
                    ch_bad = find(all(is_up_th,2));
            end
        end
    end

    methods (Static)
        
    end
end