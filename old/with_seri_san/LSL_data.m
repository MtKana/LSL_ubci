classdef LSL_data
    properties (Access = protected)
        Buffer = struct;
        para = struct;
    end
    
    %% buffer
    methods (Access = public)
        function self = LSL_data(Fs,sec,COI) 
            self.para = struct;
            self.para.Fs = Fs;
            self.para.sec = sec;
            self.para.COI = COI;
            self.para.num_ch = numel(COI);
            self.para.time_buffer = Fs * sec;
        end

        function self = set_buffer(self)
            self.Buffer.Buffer_raw = zeros(self.para.time_buffer,self.para.num_ch);
            self.Buffer.Buffer_proc = zeros(self.para.time_buffer,self.para.num_ch);
        end

        function self = reflesh_buffer(self,data)
            num_samp = size(data,1); 
            self.Buffer.Buffer_raw(1:end-num_samp,:) = self.Buffer.Buffer_raw(1+num_samp:end,:);
            self.Buffer.Buffer_raw(end-num_samp+1:end,:) = data;            
        end        
    end
end