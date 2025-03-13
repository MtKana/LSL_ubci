classdef LSL_EGI_goNoGo < LSL_data
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
        go_ratio
        trial_sequence
    end
    
    methods (Access = public)
        function self = LSL_EGI_goNoGo(Fs, sec, COI, block_n, trial_n, go_ratio)
            self@LSL_data(Fs, sec, COI);
            
            %% Set parameters
            self.block_n = block_n;
            self.trial_n = trial_n;
            self.current_block = 1;
            self.current_trial = 1;
            self.go_ratio = go_ratio;

            %% State settings (values in number of calls, since time_keeper is called every 0.1s)
            self.state.udp     = 0;
            self.state.trigger = 0;
            self.state.ready   = 1;   % Ready duration (1000 ms)
            self.state.fixation = 11; % Fixation cross duration (800 ms)
            self.state.stimulus = 18; % Stimulus duration (400 ms)
            self.state.response = 22; % Response window (1000 ms)
            self.state.end      = 32;
            self.data.count = 0;
            self.data.running = 0;

            %% Generate randomized trial sequence (Go:No-Go ratio)
            total_go = round(go_ratio * trial_n);
            total_nogo = trial_n - total_go;
            self.trial_sequence = [ones(1, total_go), zeros(1, total_nogo)];
            self.trial_sequence = self.trial_sequence(randperm(length(self.trial_sequence)));

            %% Figure settings
            self.fig.str = 0;
            self.fig.initial_pos  = [500 350 600 200];
            self.fig.original_pos = [650 400 300 100];

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
            self.fp = figure('Units', 'pixels', 'Position', get(0, 'ScreenSize'), 'WindowState', 'maximized'); % Full true fullscreen
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

        function self = show_protocol(self)
            self.fig.trial_num.String = sprintf('Trial %d', self.current_trial);
            if self.data.count == 0
                if self.current_trial >= self.trial_n && self.current_block > self.block_n
                    self.fig.str.String = 'Experiment End';
                    self.fig.str.Color = 'yellow';
                elseif self.current_trial == 1 && self.current_block <= self.block_n
                    self.fig.str.String = 'Break';
                    self.fig.str.Color = 'yellow';
                end
            elseif self.data.count == self.state.ready
                self.daq.NS.sendCommand(1);
                beep;
                self.fig.str.String = 'Ready';
                self.fig.str.Color = 'white';
            elseif self.data.count == self.state.fixation
                self.daq.NS.sendCommand(1);
                self.fig.str.String = '+';
                self.fig.str.Color = 'white';
            elseif self.data.count == self.state.stimulus
                if self.current_trial <= self.trial_n
                    if self.trial_sequence(self.current_trial) == 1
                        self.daq.NS.sendCommand(1);
                        self.fig.str.String = 'Go';
                        self.fig.str.Color = 'green';
                    else
                        self.daq.NS.sendCommand(1);
                        self.fig.str.String = 'No-go';
                        self.fig.str.Color = 'red';
                    end
                end
            elseif self.data.count == self.state.response
                self.daq.NS.sendCommand(1);
                self.fig.str.String = '';
            elseif self.data.count == self.state.end
                self.daq.NS.sendCommand(1);
                self.fig.str.String = '';
            end
        end
    end
end