classdef HelperEEGProcess
    methods (Static)

        function data_psd = fft_eeg(signal_eeg,Fs)
            arguments
                signal_eeg = [];
                Fs = 1000;
            end
            if isempty(signal_eeg)
                data_psd = [];
            else
                AE = analysis_EEG;
                AE = AE.inputData(signal_eeg,Fs);
                AE = AE.fftEEG(AE);
                data_psd = AE.tbl_fft;
            end
        end

        function data_ERSP = calc_ERSP(data_psd,range_ref)
            % data_psd[time freq ch trial], range_ref
            assert(nargin == 2, 'This function requires two variables');
            ref = mean(data_psd(range_ref,:,:,:),1);
            data_ERSP = 100*(data_psd-ref)./ref;
        end

    end
end