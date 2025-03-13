classdef LSL_EGI_MID < LSL_data
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
        trial=types
        target_flash_time % Randomized flash timing within target period
    end
    
    methods (Access = public)
        function self = LSL_EGI_MID(Fs, sec, COI, block_n, trial_n)
            self@LSL_data(Fs, sec, COI);
            
            %% Set parameters
            self.block_n = block_n;
            self.trial_n = trial_n;
            self.current_block = 1;
            self.current_trial = 1;

            %% State settings (values in number of calls, since time_keeper is called every 0.1s)
            self.state.ready = 1;      % Ready period (1000 ms)
            self.state.cue = 11;       % Cue presentation (1000 ms)
            self.state.fixation = 21;  % Fixation cross (500 ms)
            self.state.target = 26;    % Target stimulus (3000 ms)
            self.state.feedback = 56;  % Feedback period (1000 ms)
            self.state.end = 66;
            self.data.count = 0;
            self.data.running = 0;
            self.state.udp     = 0;
            self.state.trigger = 0;
            
            %% Generate randomized target flash times (between 0 and 3000 ms)
            self.target_flash_time = randi([0 2900], 1, trial_n) / 100; % Convert to 10 seconds unit
            
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
                self.fig.str.String = 'Get Ready';
                self.fig.str.Color = 'white';
            elseif self.data.count == self.state.cue
                self.daq.NS.sendCommand(1);
                self.fig.str.String = '●'; % Reward cue (Green Circle)
                self.fig.str.Color = 'green';
            elseif self.data.count == self.state.fixation
                self.daq.NS.sendCommand(1);
                self.fig.str.String = '+';
                self.fig.str.Color = 'white';
            elseif self.data.count == self.state.target
                self.daq.NS.sendCommand(1);
                self.fig.str.String = '';
            elseif self.data.count > self.state.target && self.data.count < self.state.feedback
                % Random flash within the 300 ms target window
                flash_time = self.target_flash_time(self.current_trial); % Convert to state steps
                if self.data.count == self.state.target + 1 + round(flash_time)
                    self.fig.str.String = '■'; % Target symbol (Square)
                    self.fig.str.Color = 'white';
                else
                    self.fig.str.String = '';
                end
            elseif self.data.count == self.state.feedback
                self.daq.NS.sendCommand(1);
                self.fig.str.String = 'You won $1!'; % Feedback (Modify later based on RT)
                self.fig.str.Color = 'yellow';
            elseif self.data.count == self.state.end
                self.daq.NS.sendCommand(1);
                self.fig.str.String = '';
            end
        end
    end
end
