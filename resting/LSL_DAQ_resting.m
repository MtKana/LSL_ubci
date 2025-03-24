classdef LSL_DAQ_resting < LSL_data
    properties (Access = public)
        state  = struct;
        data   = struct;
        fig    = struct;
        daq    = struct;
        data_daq 
        fp
        udpR
        block_n
        current_block % Current block counter
    end
    
    methods (Access = public)
        %% LSL_DAQ
        function self = LSL_DAQ_resting(Fs, sec, COI, block_n)
            self@LSL_data(Fs, sec, COI)
            
            self.block_n = block_n; % Set number of repetitions
            self.current_block = 1;  % Initialize repetition counter
            self.state.udp     = 0;  % 0:no udp, 1:read udp
            self.state.trigger = 0;  % 1(key 'q' pressed, exp. bDAQn)
            self.data.count  = 0;
            self.data.running = 0;
            
            self.state.relax   = 0;      % relax (5 sec)
            self.state.close_1 = 50;    % close (60 sec)
            self.state.open_1  = 650;   % open  (60 sec)
            self.state.close_2 = 1250;  % close (60 sec)
            self.state.open_2  = 1850;  % open  (60 sec)
            self.state.end     = 2450;  % end of one loop

%             self.state.relax   = 1;      % relax (5 sec)
%             self.state.close_1 = 50;    % close (5 sec)
%             self.state.open_1  = 100;   % open  (5 sec)
%             self.state.close_2 = 150;  % close (5 sec)
%             self.state.open_2  = 200;  % open  (5 sec)
%             self.state.end     = 250;  % end of one loop
            
            %% Figure settings
            self.fig.str = 0;
            self.fig.initial_pos  = [500 350 600 200];
            self.fig.original_pos = [650 400 300 100];
            
            %% DAQ setup
            self.daq.ID = 'Dev2';
            self.daq.NS = DAQclass(self.daq.ID);
            self.daq.NS = self.daq.NS.init_output;
            self.data_daq = [];
            
            %% UDP setup
            self.udpR = ReceiverUDP();
            self.udpR.set_config(5500, "127.0.0.5", 0.05);
            self.udpR.start();
        end           
        
        function self = setup_protocol(self)
            self.fp = figure('Units', 'pixels', 'Position', get(0, 'ScreenSize'), 'WindowState', 'maximized'); % Fullscreen
            set(self.fp, 'color', 'black', 'menu', 'none', 'toolbar', 'none');
            hold on;
            self.fig.block_num = text(0.02, 0.98, '', 'fontsize', 50, 'fontname', 'Arial', 'color', 'white', 'HorizontalAlignment', 'left', 'Units', 'normalized');
            self.fig.str = text(0.5, 0.5, '', 'fontsize', 100, 'fontname', 'Arial', 'color', 'white', 'HorizontalAlignment', 'center', 'Units', 'normalized');
            axis off;
        end
        
        %% Time keeper
        function self = time_keeper(self)
            dbstop if error;
            if self.state.trigger == 1 && self.data.running == 1
                self.data.count = self.data.count + 1;
                
                %% If time reaches the end of one loop, reset for the next repeat
                if self.data.count == self.state.end
                    self.data.count = 0;
                    if self.current_block < self.block_n
                        self.current_block = self.current_block + 1;
                        self.data.running = 0;
                    else
                        self.current_block = self.current_block + 1;
                        self.data.running = 0;
                        self.state.trigger = 0;
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
                        self.data.running = 1;
                        self.data.count = 0;
                    end
                    
                    %% Refresh data
                    self.udpR.data_recv = [];
                end
            end
        end

        function self = process_daq(self, daq_data)
            % Update Block Number Display to Show Data as Well
            self.data_daq = daq_data; 
            value = self.data_daq(1, 4);
            self.fig.block_num.String = sprintf(['Block %d\n' ...
                'First Row, Fourth Column: %.4f'], ...
                self.current_block, value);
            drawnow;
        end


        %% Show protocol
        function self = show_protocol(self)
            dbstop if error;
            if self.data.count == 0
                if self.current_block > self.block_n
                    self.fig.str.String = 'Experiment end';
                    self.fig.str.Color = 'white';
                elseif self.current_block <= self.block_n
                    self.fig.str.String = 'Please wait...';
                    self.fig.str.Color = 'white';
                end
            elseif self.data.count == self.state.relax
                self.daq.NS.sendCommand(1);
                self.fig.str.Color  = 'white';
                self.fig.str.String = '+';
                beep;
            elseif self.data.count == self.state.close_1
                self.daq.NS.sendCommand(1);
                self.fig.str.Color  = 'green';
                self.fig.str.String = 'Close';
                beep;
                
            elseif self.data.count == self.state.open_1 
                self.daq.NS.sendCommand(1);
                self.fig.str.Color  = 'yellow';
                self.fig.str.String = 'Open';
                beep;
                
            elseif self.data.count == self.state.close_2 
                self.daq.NS.sendCommand(1);
                self.fig.str.Color  = 'green';
                self.fig.str.String = 'Close';
                beep;
                
            elseif self.data.count == self.state.open_2 
                self.daq.NS.sendCommand(1);
                self.fig.str.Color  = 'yellow';
                self.fig.str.String = 'Open';
                beep;
                
            elseif self.data.count == self.state.end
                self.daq.NS.sendCommand(1);
                self.fig.str.String = '';
            end
        end
    end
end
