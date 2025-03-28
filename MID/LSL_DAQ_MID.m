classdef LSL_DAQ_MID < LSL_data
    properties (Access = public)
        state  = struct;
        data   = struct;
        fig    = struct;
        daq    = struct;
        fp
        udpR
        block_n
        trial_n
        current_block
        current_trial
        trial_sequence
        trial_types
        target_flash_time
        data_daq
        detected_response % Track button press within valid response window
    end
    
    methods (Access = public)
        function self = LSL_DAQ_MID(Fs, sec, COI, block_n, trial_n)
            dbstop if error;
            self@LSL_data(Fs, sec, COI);
            
            %% Set parameters
            self.block_n = block_n;
            self.trial_n = trial_n;
            self.current_block = 1;
            self.current_trial = 1;
            self.detected_response = false;
            self.data_daq = [];

            %% State settings (values in number of calls, since time_keeper is called every 0.1s)
            self.state.ready = 1;      % Ready period (300 ms)
            self.state.cue = 4;       % Cue presentation (700 ms)
            self.state.fixation = 11;  % Fixation cross (200 ms)
            self.state.target = 13;    % Target stimulus (1000 ms)
            self.state.feedback = 35;  % Feedback period (500 ms)
            self.state.end = 40;
            self.data.count = 0;
            self.data.running = 0;
            self.state.udp     = 0;
            self.state.trigger = 0;

            %% Generate balanced trial types (1: Reward, 2: Neutral, 3: Loss)
            n_each = floor(trial_n / 3);
            self.trial_types = [ones(1, n_each), 2*ones(1, n_each), 3*ones(1, n_each)];
            self.trial_types = self.trial_types(randperm(length(self.trial_types))); % Shuffle trials            
            
            %% Generate randomized target flash times (between 0 and 3000 ms)
            self.target_flash_time = randi([0 1000], 1, trial_n) / 100; % Convert to 10 seconds unit
            
            %% Figure settings
            self.fig.str = 0;
            
            %% DAQ settings
            self.daq.ID = 'Dev2';
            self.daq.NS = DAQclass(self.daq.ID);
            self.daq.NS = self.daq.NS.init_output;
            
            %% UDP settings
            self.udpR = ReceiverUDP();
            self.udpR.set_config(5500, "127.0.0.5", 0.05);
            self.udpR.start();
        end                

        function self = setup_protocol(self)
            dbstop if error;
            self.fp = figure('Units', 'pixels', 'Position', get(0, 'ScreenSize'), 'WindowState', 'maximized');
            set(self.fp, 'color', 'black', 'menu', 'none', 'toolbar', 'none');
            hold on;
            self.fig.trial_num = text(0.02, 0.98, '', 'fontsize', 50, 'fontname', 'Arial', 'color', 'white', 'HorizontalAlignment', 'left', 'Units', 'normalized');
            self.fig.str = text(0.5, 0.5, '', 'fontsize', 80, 'fontname', 'Arial', 'color', 'white', 'HorizontalAlignment', 'center', 'Units', 'normalized');
            axis off;
        end

        function self = time_keeper(self)
            dbstop if error;
            if self.state.trigger == 1 && self.data.running == 1
                self.data.count = self.data.count + 1;
                if self.data.count == self.state.end
                    self.data.count = 0;
                    if self.current_trial < self.trial_n % Prevent exceeding trial count
                        self.current_trial = self.current_trial + 1;
                    else
                        if self.current_block < self.block_n
                            self.current_trial = 1;
                            self.current_block = self.current_block + 1;
                            self.data.running = 0;
                        else
                            self.current_block = self.current_block + 1;
                            self.data.running = 0;
                            self.state.trigger = 0;
                        end
                    end
                end
            end
            
            if self.state.udp == 0
                self.udpR.read();
                if ~isempty(self.udpR.data_recv)  
                    if contains(self.udpR.data_recv, "q")
                        self.state.trigger = 1;
                        self.data.running = 1;
                        self.data.count = 0;
                        self.current_trial = 1;
                    end
                    
                    self.udpR.data_recv = [];
                end
            end
        end

        function self = process_daq(self, daq_data)
            dbstop if error;
            self.data_daq = daq_data; 
            self.fig.trial_num.String = sprintf('Block: %d | Trial: %d', self.current_block, self.current_trial);
            drawnow;
%             % Monitor DAQ data ONLY during the 300ms response window
%             flash_time = self.target_flash_time(self.current_trial);
%             response_window_start = self.state.target + 1 + round(flash_time);
%             responsqqe_window_end = response_window_start + 3; % 300ms = 3 cycles of 0.1s
% 
%             if self.data.count >= response_window_start && self.data.count <= response_window_end
%                 if any(self.data_daq(:, 4) > 1)
%                     self.detected_response = true; % Mark response detected
%                 end
%             end
        end

        function self = show_protocol(self)
            dbstop if error;
            trial_type = self.trial_types(self.current_trial);
            flash_time = self.target_flash_time(self.current_trial);
            response_window_start = self.state.target + 1 + round(flash_time);
            
            if self.data.count == 0
                self.detected_response = false; % Reset detected response at the start of each trial
                if self.current_trial >= self.trial_n && self.current_block > self.block_n
                    self.fig.str.String = 'Experiment end';
                    self.fig.str.Color = 'white';
                elseif self.current_trial == 1 && self.current_block <= self.block_n
                    self.fig.str.String = 'Please wait';
                    self.fig.str.Color = 'white';
                end
            elseif self.data.count == self.state.ready
                self.daq.NS.sendCommand(1);
                beep;
                self.fig.str.String = '';
                self.fig.str.Color = 'white';
            elseif self.data.count == self.state.cue
                if trial_type == 1
                    self.daq.NS.sendCommand(2);
                    self.fig.str.String = char(9816); % Reward cue (Green Circle)
                    self.fig.str.FontName = 'Arial Unicode MS';
                    self.fig.str.Color = 'blue';
                elseif trial_type == 2
                    self.daq.NS.sendCommand(1);
                    self.fig.str.String = char(9731); % Neutral cue (Gray Circle)
                    self.fig.str.FontName = 'Arial Unicode MS';
                    self.fig.str.Color = 'magenta';
                else
                    self.daq.NS.sendCommand(3);
                    self.fig.str.String = char(9836); % Loss cue (Red Circle)
                    self.fig.str.FontName = 'Arial Unicode MS';
                    self.fig.str.Color = 'yellow';
                end
            elseif self.data.count == self.state.fixation
                self.daq.NS.sendCommand(1);
                self.fig.str.String = '+';
                self.fig.str.Color = 'white';
            elseif self.data.count == self.state.target
                self.daq.NS.sendCommand(1);
                self.fig.str.String = '';
            elseif self.data.count == response_window_start
                % Display square symbol (target stimulus)
                self.fig.str.String = '■';
                if trial_type == 1
                    self.fig.str.Color = 'blue';
                elseif trial_type == 2
                    self.fig.str.Color = 'magenta';
                else
                    self.fig.str.Color = 'yellow';
                end
            elseif self.data.count == response_window_start + 1
                self.fig.str.String = '';
            elseif self.data.count > response_window_start + 1 && self.data.count < response_window_start + 7
                if any(self.data_daq(:, 4) > 1)
                    self.detected_response = true; % Mark response detected
                end
            elseif self.data.count == self.state.feedback
                % Feedback based on response
                if trial_type == 1  % Reward trial
                    if self.detected_response == true
                        self.daq.NS.sendCommand(4);
                        self.fig.str.String = 'You won $1!';
                        self.fig.str.Color = 'green';
                    else
                        self.daq.NS.sendCommand(1);
                        self.fig.str.String = 'No reward';
                        self.fig.str.Color = 'red';
                    end
                elseif trial_type == 2  % Neutral trial
                    if self.detected_response == true
                        self.daq.NS.sendCommand(4);
                        self.fig.str.String = 'good response +-0';
                        self.fig.str.Color = 'green';
                    else
                        self.daq.NS.sendCommand(1);
                        self.fig.str.String = 'bad response +-0';
                        self.fig.str.Color = 'red';
                    end
                else  % Loss trial
                    if self.detected_response == true
                        self.daq.NS.sendCommand(4);
                        self.fig.str.String = 'You avoided losing $1!';
                        self.fig.str.Color = 'green';
                    else
                        self.daq.NS.sendCommand(1);
                        self.fig.str.String = 'You lost $1!';
                        self.fig.str.Color = 'red';
                    end
                end
            elseif self.data.count == self.state.end 
                self.daq.NS.sendCommand(1);
                self.fig.str.String = '';
            end
        end
    end
end