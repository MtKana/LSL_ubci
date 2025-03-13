classdef DAQclass
    
    properties
        DevID
        para
        out
    end
    
    methods(Static)
        
        function OutputSignal = zeropad(OutputSignal)
            OutputSignal = cat(3, OutputSignal, zeros(size(OutputSignal)));
            OutputSignal = permute(OutputSignal, [3, 2, 1]);
        end
        
        function out = generateStruct(varlist)            
            place_list = 'caller';
            out = struct;
            for i_var = 1:numel(varlist)
                out.(varlist{i_var}) = evalin(place_list, sprintf('%s', varlist{i_var}));
            end
        end
    end
    
    methods (Access = private)
        
        function para = setPara_DAQ(DAQ)
            OutputSignal = ...
                [5,0,0,0;...
                0,5,0,0;...
                5,5,0,0;...
                0,0,5,0;...
                5,0,5,0;...
                0,5,5,0;...
                5,5,5,0;...
                0,0,0,5;...
                5,0,0,5;...
                0,5,0,5;]; % DIN1~10
            repnum = 10;
            OutputSignal = repmat(OutputSignal, [1, 1, repnum]);
            OutputSignal = DAQ.zeropad(OutputSignal);
            refleshDIN = zeros(2, 4);
            var = who;
            var(strcmp(var, 'DAQ')) = [];
            para = DAQ.generateStruct(var);
        end
        
        function command = getCommand(DAQ, command)
            if command ~= 0
                command = DAQ.para.OutputSignal(:,:,command);
            else
                command = DAQ.para.refleshDIN;
            end
        end
    end
    
    methods (Access = public)
        
        function sendCommand(DAQ, command)
            if isempty(command) || isnan(command)
                fprintf('Skip DIN send\n')
                return
            end
            command_DIN = DAQ.getCommand(command);
            try
                DAQ.out.write(command_DIN);
                DAQ.out.start();
                fprintf('DIN sent %02d \n', command)
            catch
                fprintf('delayed\n')
                pause(0.1);
                DAQ.out.write(command_DIN);
                DAQ.out.start();
            end
        end
    end
    
    methods (Access = public)
        
        function DAQ = DAQclass(DevID)
            assert(nargin == 1, 'Input DevID is required.');
            DAQ.DevID = DevID;
            DAQ.para = DAQ.setPara_DAQ;
        end
        
        function DAQ = init_output(DAQ)
            D_out = daq('ni');
            D_out.addoutput(DAQ.DevID, [0 1 2 3], 'voltage');
            DAQ.out = D_out;
            DAQ.out.write(DAQ.para.refleshDIN);
            DAQ.out.start();
        end
        
        function DAQ = stop_output(DAQ)
            DAQ.sendCommand(0);
            stop(DAQ.out);
        end
    end
end
