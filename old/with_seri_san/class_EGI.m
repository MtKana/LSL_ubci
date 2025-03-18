classdef class_EGI
    properties (Access = public)
        para = struct;
        buffer = struct;
        result = struct;
    end

    methods (Access = public)
        %% class EGI
        function self = class_EGI(fs) 
            self.para.Fs = fs;
            self.para.frq = 50;
            self.para.notch = 50;
            self.para.h = hanning(self.para.Fs);
            [self.para.bpb,self.para.bpa] = butter(3,[3 70]/(self.para.Fs/2));
            [self.para.ncb,self.para.nca] = butter(3,[self.para.notch-1 self.para.notch+1]/(self.para.Fs/2),'stop');
            self.para.h_p = repmat(self.para.h,[1,128]);

            self.result.tempSignal = 0;
            self.result.temp_fft = 0;
            self.result.in = 0;
            self.result.out = 0;
            self.result.ref = zeros(self.para.frq,128);
            self.result.ersp = 0;
        end

        %% fft & power mean
        function self = calc_power(self)
            self.result.tempSignal = self.result.in .* self.para.h_p;

            self.result.temp_fft = abs(fft(self.result.tempSignal,2^nextpow2(self.para.Fs),1)).^2; 
            self.result.out = self.result.temp_fft(1:self.para.frq,:);  
        end

        %% filtfilt: bandpass + notch
        function self = filtfilt(self,buffer)
            self.result.in = filtfilt(self.para.bpb,self.para.bpa, ...
                filtfilt(self.para.ncb,self.para.nca,buffer));
        end    
    end
end
       