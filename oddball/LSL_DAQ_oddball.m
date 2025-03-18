classdef LSL_DAQ_oddball < LSL_data
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
        detected_response % Track user response
        data_daq % Store DAQ data
    end
    
    methods (Access = public)
        function self = LSL_DAQ_oddball(Fs, sec, COI, block_n, trial_n)
            self@LSL_data(Fs, sec, COI);
            
            %% Set parameters
            self.block_n = block_n;
            self.trial_n = trial_n;
            self.current_block = 1;
            self.current_trial = 1;
            self.detected_response = false; % Initialize response tracker
            self.data_daq = []; % Initialize DAQ data

            %% State settings (values in number of calls, since time_keeper is called every 0.1s)
            self.state.ready = 1;      % Ready period (1500 ms)
            self.state.fixation = 16;  % Fixation cross (1000 ms)
            self.state.target = 26;    % Target stimulus (300 ms)
            self.state.response = 29;  % Response period (1000 ms)
            self.state.end = 39;
            self.data.count = 0;
            self.data.running = 0;
            self.state.udp     = 0;
            self.state.trigger = 0;

            %% Generate balanced trial types for Oddball Task (Standard ~75%, Target ~25%)
            n_standard = round(trial_n * 0.75);
            n_target = trial_n - n_standard; % Remaining trials for target         
            self.trial_types = [ones(1, n_standard), 2*ones(1, n_target)];
            self.trial_types = self.trial_types(randperm(length(self.trial_types))); % Shuffle trials

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
            self.fp = figure('Units', 'pixels', 'Position', get(0, 'ScreenSize'), 'WindowState', 'maximized');
            set(self.fp, 'color', 'black', 'menu', 'none', 'toolbar', 'none');
            hold on;
            self.fig.trial_num = text(0.02, 0.98, '', 'fontsize', 50, 'fontname', 'Arial', 'color', 'white', 'HorizontalAlignment', 'left', 'Units', 'normalized');
            self.fig.str = text(0.5, 0.5, '', 'fontsize', 100, 'fontname', 'Arial', 'color', 'white', 'HorizontalAlignment', 'center', 'Units', 'normalized');
            axis off;
        end

        function self = time_keeper(self)
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
            value = self.data_daq(1, 4); % Extract value
            self.fig.trial_num.String = sprintf('Block: %d | Trial: %d | DAQ: %.2f', self.current_block, self.current_trial, value);
            drawnow;
            
            % Monitor DAQ data during response window
            if self.data.count >= self.state.response && self.data.count < self.state.end
                if any(self.data_daq(:, 4) > 1)
                    self.detected_response = true; % Mark response detected
                end
            end
        end


        function self = show_protocol(self)
            self.fig.trial_num.String = sprintf('Trial %d', self.current_trial);
            trial_type = self.trial_types(self.current_trial);
            
            if self.data.count == 0
                if self.current_trial >= self.trial_n && self.current_block > self.block_n
                    self.fig.str.String = 'Experiment end';
                    self.fig.str.Color = 'white';
                elseif self.current_trial == 1 && self.current_block <= self.block_n
                    self.fig.str.String = 'Please wait...';
                    self.fig.str.Color = 'white';
                end
            elseif self.data.count == self.state.ready
                self.daq.NS.sendCommand(1);
                beep;
                self.fig.str.String = 'Get ready';
                self.fig.str.Color = 'white';
            elseif self.data.count == self.state.fixation
                self.daq.NS.sendCommand(1);
                self.fig.str.String = '+';
                self.fig.str.Color = 'white';
            elseif self.data.count == self.state.target
                self.daq.NS.sendCommand(1);
                if trial_type == 1  % Standard (Frequent) Stimulus
                    self.fig.str.String = char(9816);
                    self.fig.str.FontName = 'Arial Unicode MS';
                    self.fig.str.Color = 'blue';
                elseif trial_type == 2  % Target (Rare) Stimulus
                    self.fig.str.String = char(9836);
                    self.fig.str.FontName = 'Arial Unicode MS';
                    self.fig.str.Color = 'yellow';
                end
            elseif self.data.count == self.state.response
                self.daq.NS.sendCommand(1);
                self.fig.str.String = '';
            elseif self.data.count == self.state.end
                % Determine DAQ command based on user response and trial type
                if (trial_type == 2 && self.detected_response) || (trial_type == 1 && ~self.detected_response)
                    self.daq.NS.sendCommand(4);
                elseif (trial_type == 2 && ~self.detected_response) || (trial_type == 1 && self.detected_response)
                    self.daq.NS.sendCommand(1);
                end
                self.fig.str.String = '';
            end
        end
    end
end