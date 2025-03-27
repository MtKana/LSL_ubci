classdef analysis_EMG
    properties
        Fs
        signal_EMG
        para
    end
    
    methods (Static)
        function out = multNotch(in,Fs,num_nc,nc)
            if nargin < 2
                Fs = 1000;
            end
            if nargin < 3
                num_nc = 4;
            end
            if nargin < 4
                nc = 50;
            end
            %fig; 
            for i_nc = 1 : num_nc
                [ncb,nca] = butter(3,[nc*i_nc-1 nc*i_nc+1]/(Fs/2),'stop');
                in = filtfilt(ncb,nca,in);
                %plot(in);
            end
            out = in;
        end
    end
    
    methods (Access = public)
        function AE = analysis_EMG
           AE.para = struct; 
        end
            
        function AE = inputData(AE,sig,Fs)
            AE.Fs = Fs;
            AE.signal_EMG = sig;
        end
        
        function AE = filter(AE)
            AE.signal_EMG = AE.multNotch(AE.signal_EMG);
            [bpb,bpa]     = butter(3,[3 AE.Fs/2-10]/(AE.Fs/2),'bandpass');
            AE.signal_EMG = filtfilt(bpb,bpa,AE.signal_EMG);
        end
    end
    
end