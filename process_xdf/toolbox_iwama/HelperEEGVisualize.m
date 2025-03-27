classdef HelperEEGVisualize

    methods (Static)
        function check_eeg_raw(signal,COI,Fs)
            arguments
                signal = [];
                COI = 36;
                Fs = 1000;
            end
            sig_coi = squeeze(signal(:,COI,:));
            t = 1/Fs:1/Fs:size(sig_coi,1)/Fs;
            count_trl = 0;
            trl_sp = 10;
            vi = visualize_data;            
            for i_trl = 1 : size(sig_coi,2)
                if count_trl == 0
                    vi.figure;
                    vi.setPos([1,1,560 1810]);
                end
                vi.sp(trl_sp,1,count_trl+1);
                plot(t,sig_coi(:,i_trl),'LineWidth',1.5,'Color','k');
                vi.setFig(-4,8);
                count_trl = count_trl + 1;
                if count_trl == trl_sp
                    count_trl = 0;
                end
                vi.setTitle(sprintf('Trial: %02d',i_trl));
            end
        end

        function check_psd(data_psd,idx_col)
            arguments
                data_psd = []; % [time freq ch trl]
                idx_col = 1;
            end
            if isempty(data_psd), return, end
            vi = visualize_data;
            psd = permute(data_psd,[2,1,3,4]);
            psd = reshape(psd,size(psd,1),[]);
            
            vi.plotMat(psd,vi.para_col.col(:,idx_col),1);
            vi.setFig(-6,10);
        end

        function check_tf(data_ERSP,range_caxis)
            arguments
                data_ERSP = []; % [time freq ch trl]
                range_caxis = 100;
            end
            if isempty(data_ERSP), return, end            
            vi = visualize_data;
            num_ch = size(data_ERSP,3);
            for i_ch = 1 : num_ch
                %vi.figure;
                vi.drawTF(data_ERSP,i_ch,0.9,1,1);
                vi.setCB(1,10,range_caxis);
                ylim([3 40])
            end
        end

        function check_topo(data_ERSP,list_ch,range_caxis)
            arguments
                data_ERSP = []; % [time freq ch trl]
                list_ch = 1 : size(data_ERSP,3);
                range_caxis = 100;
            end
            if isempty(data_ERSP), return, end            
            vi = visualize_data;
            data_ERSP = mean(data_ERSP,[1,2,4]);
            vi.drawTopo(data_ERSP,list_ch);
            vi.setCB(1,10,range_caxis);
        end
    end
end