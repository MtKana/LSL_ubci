classdef LSL_EGI_BMI < LSL_data
    properties (Access = public)     
        state = struct;
        data  = struct;
        fig   = struct;
        daq   = struct;
        fp
    end
    
    methods
        %% LSL_EGI
        function self = LSL_EGI_BMI(Fs,sec,COI,repeat_n)  
            self@LSL_data(Fs,sec,COI)     

            %%
            self.state.blank = 0;    % blank (5 sec)
            self.state.rest  = 5;    % rest  (10 sec)
            self.state.ready = 15;   % ready (1 sec)
            self.state.task  = 16;   % task  (10 sec)
            self.state.end   = 26;

            self.state.trigger = 1;

            %%
            self.data.sample = 10;  % 10 samples/sec (buffering duration : 0.1)
            self.data.time   = -5;
            self.data.count  = 0;

            self.data.repeat = 0;
            self.data.repeat_n = repeat_n;

            %%
%             self.fig.str = 0;
            self.fig.pos  = [0 0 1600 900];

            self.daq.ID = 'Dev2';
            self.daq.NS = DAQclass(self.daq.ID);
            self.daq.NS = self.daq.NS.init_output;
        end        

        %% setup figure (protocol)
        function self = setup_protocol(self)
            self.fp = figure;
            self.fp.Position = self.fig.pos;
            set(self.fp,'color','none','menu','none','toolbar','none');
            self.fig.str = text(2,1,'Please wait...','fontsize',50,'fontname','Arial','color','white','HorizontalAlignment','center');
            axis tight;            
            axis off;
            xlim([0 4]); 
            ylim([0 2]);
        end

        %% process_daq
        function self = process_eeg(self)
            %% time keeper
            self.data.count = self.data.count + 1;

            if self.data.count == self.data.sample + 1 
                self.data.count = 1;
                self.data.time = self.data.time + 1;
            end

%             disp(['Current time: ', num2str(self.data.time)]);  % Debugging statement to display time
        end

        %% show_protocol
        function self = show_protocol(self)
            if self.data.time == self.state.blank && self.data.count == 1  % blank     
                self.fig.str.Color  = 'white';
                self.fig.str.String = 'Blank';
                self.daq.NS.sendCommand(1)
                
            elseif self.data.time == self.state.rest && self.data.count == 1  % rest
                self.fig.str.Color  = 'green';
                self.fig.str.String = 'Rest';
                self.daq.NS.sendCommand(1)

            elseif self.data.time == self.state.ready && self.data.count == 1  % ready
                self.fig.str.Color  = 'yellow';
                self.fig.str.String = 'Ready';
                self.daq.NS.sendCommand(1)

            elseif self.data.time == self.state.task && self.data.count == 1  % task & stop
                self.fig.str.String = '';
                self.fig.str.Color  = 'red';
                self.fig.str.String = 'Imagery';
                self.daq.NS.sendCommand(1)

            elseif self.data.time == self.state.end && self.data.count == 1  % end
                self.daq.NS.sendCommand(1)

                self.data.time = self.state.blank;
                self.data.count = 0;

                self.data.repeat = self.data.repeat + 1;
                if self.data.repeat == self.data.repeat_n
                    self.data.time = self.state.end + 1;
                    self.state.trigger = 0;

                    self.fig.str.Color  = 'white';
                    self.fig.str.String = 'END';
                end
            end
        end
    end        
end
