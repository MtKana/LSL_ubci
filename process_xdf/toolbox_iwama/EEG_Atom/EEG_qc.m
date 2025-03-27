classdef EEG_qc < remove1F
    
    methods (Static)
        
        function idx_rj = EEGQC(in,Fs)
            %%% in[time ch trl]
            n             = 2;
            th            = 0.1*Fs;
            qc            = EEG_qc;
            num_dim       = qc.chkDim(in); 
            [time ch trl] = size(in);
            abs_in        = abs(in).^2;
            thirdQ        = sq(quantile(abs_in,0.75,1)); %time
            stdQ          = sq(std(abs_in,[],1));
            if num_dim == 2
                thirdQ  = thirdQ';
                stdQ    = stdQ';
            end
            t_sec         = time/Fs;
            num_win       = floor((t_sec-1)./0.1);
            idx_rj        = zeros(num_win,ch,trl);
            for i_trl = 1 : trl
                for i_ch = 1 : ch
                    th_EEG = thirdQ(i_ch,i_trl)+n*stdQ(i_ch,i_trl);
                    for i_win = 1 : num_win
                        s      = 1 + 0.1*Fs*(i_win-1): Fs + 0.1*Fs*(i_win-1);
                        num_ol = sum(abs_in(s,i_ch,i_trl)>th_EEG);
                        if num_ol > th
                            idx_rj(i_win,i_ch,i_trl) = 1;
                        end
                    end
                end
            end            
            
        end
        
    end
    
    methods (Static)
        
        function num_dim = chkDim(in)
            sz      = size(in);
            sz(sz==1)= [];
            num_dim = numel(sz);            
        end
    end
        
end