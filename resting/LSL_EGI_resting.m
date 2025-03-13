classdef LSL_EGI_resting < LSL_data
    properties (Access = public)
        state  = struct;
        data   = struct;
        fig    = struct;
        daq    = struct;
        fp
        udpR
        repeat_n  % Number of times to repeat the trial
        current_repeat % Current repetition counter
    end
    
    methods (Access = public)
        %% LSL_EGI
        function self = LSL_EGI_resting(Fs, sec, COI, repeat_n)
            self@LSL_data(Fs, sec, COI)
            
            self.repeat_n = repeat_n; % Set number of repetitions
            self.current_repeat = 1;  % Initialize repetition counter
            
            %% Experiment state settings
            self.state.udp     = 0;  % 0:no udp, 1:read udp
            self.state.trigger = 0;  % 1(key 'q' pressed, exp. begin)
            
%             self.state.relax   = 0;      % relax (5 sec)
%             self.state.close_1 = 5;    % close (60 sec)
%             self.state.open_1  = 65;   % open  (60 sec)
%             self.state.close_2 = 125;  % close (60 sec)
%             self.state.open_2  = 185;  % open  (60 sec)
%             self.state.end     = 245;  % end of one loop

            self.state.relax   = 0;      % relax (5 sec)
            self.state.close_1 = 5;    % close (5 sec)
            self.state.open_1  = 10;   % open  (5 sec)
            self.state.close_2 = 15;  % close (5 sec)
            self.state.open_2  = 20;  % open  (5 sec)
            self.state.end     = 25;  % end of one loop
            
            %% Data tracking
            self.data.sample = 10;  % 10 samples/sec (buffering duration : 0.1)
            self.data.time   = 0;
            self.data.count  = 0;
            
            %% Figure settings
            self.fig.str = 0;
            self.fig.initial_pos  = [500 350 600 200];
            self.fig.original_pos = [650 400 300 100];
            
            %% DAQ setup
            self.daq.ID = 'Dev2';
            self.daq.NS = DAQclass(self.daq.ID);
            self.daq.NS = self.daq.NS.init_output;
            
            %% UDP setup
            self.udpR = ReceiverUDP();
            self.udpR.set_config(5500, "127.0.0.5", 0.05);
            self.udpR.start();
        end           
        
        function self = setup_protocol(self)
            self.fp = figure('Units', 'pixels', 'Position', get(0, 'ScreenSize'), 'WindowState', 'maximized'); % Fullscreen
            set(self.fp, 'color', 'black', 'menu', 'none', 'toolbar', 'none');
            hold on;
            self.fig.str = text(0.5, 0.5, 'Please wait...', 'fontsize', 100, 'fontname', 'Arial', 'color', 'white', 'HorizontalAlignment', 'center', 'Units', 'normalized');
            axis off;
        end
        
        %% Time keeper
        function self = time_keeper(self)
            dbstop if error;
            if self.state.trigger == 1
                self.data.count = self.data.count + 1;
    
                if self.data.count == self.data.sample + 1 
                    self.data.count = 1;
                    self.data.time = self.data.time + 1;
                end
                
                %% If time reaches the end of one loop, reset for the next repeat
                if self.data.time == self.state.end && self.data.count == 1 
                    if self.current_repeat < self.repeat_n
                        self.current_repeat = self.current_repeat + 1;
                        self.data.time = 0;
                    else
                        self.current_repeat = self.current_repeat + 1;
                        self.state.trigger = 0; % Stop experiment after repeat_n loops
                    end
                end
            end
            
            %% Receive UDP
            if self.state.udp == 0
                self.udpR.read();
    
                if ~isempty(self.udpR.data_recv)  
                    %% Check start of trial
                    if contains(self.udpR.data_recv, "q")
                        self.state.trigger = 1;
                        self.data.time = 0;
                        self.data.count = 1;
                        self.current_repeat = 1; % Reset repetition counter
%                         self.daq.NS.sendCommand(1);
                    end
                    
                    %% Refresh data
                    self.udpR.data_recv = [];
                end
            end
        end
        
        %% Show protocol
        function self = show_protocol(self)
            dbstop if error;
            if self.data.time == self.state.relax && self.data.count == 1  % Relax
                self.daq.NS.sendCommand(1);
                self.fig.str.Color  = 'white';
                self.fig.str.String = sprintf('Loop %d/%d', self.current_repeat, self.repeat_n);
                beep;
                
            elseif self.data.time == self.state.close_1 && self.data.count == 1  % Close
                self.daq.NS.sendCommand(1);
                self.fig.str.Color  = 'green';
                self.fig.str.String = 'Close';
                beep;
                
            elseif self.data.time == self.state.open_1 && self.data.count == 1  % Open
                self.daq.NS.sendCommand(1);
                self.fig.str.Color  = 'yellow';
                self.fig.str.String = 'Open';
                beep;
                
            elseif self.data.time == self.state.close_2 && self.data.count == 1  % Close
                self.daq.NS.sendCommand(1);
                self.fig.str.Color  = 'green';
                self.fig.str.String = 'Close';
                beep;
                
            elseif self.data.time == self.state.open_2 && self.data.count == 1  % Open
                self.daq.NS.sendCommand(1);
                self.fig.str.Color  = 'yellow';
                self.fig.str.String = 'Open';
                beep;
                
            elseif self.data.time == self.state.end && self.data.count == 1  % End of loop
                if self.current_repeat < self.repeat_n
                    self.daq.NS.sendCommand(1);
                    self.fig.str.String = '';
                else
                    self.fig.str.Color  = 'blue';
                    self.fig.str.String = 'END';
                    if self.current_repeat == self.repeat_n
                        self.daq.NS.sendCommand(1);
                        beep;
                    end
                end
            end
        end
    end
end
