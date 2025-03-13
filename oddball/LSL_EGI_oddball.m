classdef LSL_EGI_oddball < LSL_data
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
    end
    
    methods (Access = public)
        function self = LSL_EGI_oddball(Fs, sec, COI, block_n, trial_n)
            self@LSL_data(Fs, sec, COI);
            
            %% Set parameters
            self.block_n = block_n;
            self.trial_n = trial_n;
            self.current_block = 1;
            self.current_trial = 1;

            %% State settings (values in number of calls, since time_keeper is called every 0.1s)
            self.state.ready = 1;      % Ready period (300 ms)
            self.state.fixation = 4;  % Fixation cross (300 ms)
            self.state.target = 7;    % Target stimulus (300 ms)
            self.state.response = 10;  % Response period (1000 ms)
            self.state.blank = 20;     % Blank period (500 ms)
            self.state.end = 25;
            self.data.count = 0;
            self.data.running = 0;
            self.state.udp     = 0;
            self.state.trigger = 0;

            %% Generate balanced trial types for Oddball Task (Standard ~75%, Target ~20%, Distractor ~5%)
            n_standard = round(trial_n * 0.75);
            n_target = round(trial_n * 0.20);
            n_distractor = trial_n - (n_standard + n_target); % Remaining trials for distractor         
            self.trial_types = [ones(1, n_standard), 2*ones(1, n_target), 3*ones(1, n_distractor)];
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
            self.fp = figure('Units', 'pixels', 'Position', get(0, 'ScreenSize'), 'WindowState', 'maximized'); % Fullscreen
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
                    if self.current_trial < self.trial_n
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
                    self.fig.str.String = 'O'; % Example standard stimulus
                    self.fig.str.Color = 'blue';
                elseif trial_type == 2  % Target (Rare) Stimulus
                    self.fig.str.String = 'X'; % Example target stimulus
                    self.fig.str.Color = 'yellow';
                elseif trial_type == 3  % Distractor Stimulus (if used)
                    self.fig.str.String = '*'; % Example distractor stimulus
                    self.fig.str.Color = 'red';
                end
            elseif self.data.count == self.state.response
                self.daq.NS.sendCommand(1);
                self.fig.str.String = '';
            elseif self.data.count == self.state.blank
                self.daq.NS.sendCommand(1);
                self.fig.str.String = '';
            elseif self.data.count == self.state.end
                self.daq.NS.sendCommand(1);
                self.fig.str.String = '';
            end
        end
    end
end
