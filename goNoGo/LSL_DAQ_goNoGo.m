classdef LSL_DAQ_goNoGo < LSL_data
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
        data_daq
        feedback_type % Stores feedback type
        detected_response % Flag to track if data_daq > 2 detected during response window
    end
    
    methods (Access = public)
        function self = LSL_DAQ_goNoGo(Fs, sec, COI, block_n, trial_n, go_ratio)
            self@LSL_data(Fs, sec, COI);
            
            %% Set parameters
            self.block_n = block_n;
            self.trial_n = trial_n;
            self.current_block = 1;
            self.current_trial = 1;
            self.go_ratio = go_ratio;
            self.data_daq = [];
            self.feedback_type = []; % Initialize feedback type
            self.detected_response = false; % Flag for DAQ > 2 detection

            %% State settings
            self.state.rest   = 1;   
            self.state.fixation = 11; 
            self.state.stimulus = 21; 
            self.state.response = 24; 
            self.state.feedback = 34; 
            self.state.end = 44;
            self.data.count = 0;
            self.data.running = 0;
            self.state.udp     = 0;
            self.state.trigger = 0;

            %% Generate randomized trial sequence
            total_go = round(go_ratio * trial_n);
            total_nogo = trial_n - total_go;
            self.trial_sequence = [ones(1, total_go), zeros(1, total_nogo)];
            self.trial_sequence = self.trial_sequence(randperm(length(self.trial_sequence)));

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
            if self.data.count >= self.state.response && self.data.count < self.state.feedback
                if any(self.data_daq(:, 4) > 1.5)
                    self.detected_response = true; % Mark response detected
                end
            end
        end

        function self = show_protocol(self)
            dbstop if error;
            if self.data.count == 0
                % Reset feedback type and response detection flag at the start of each trial
                self.feedback_type = [];
                self.detected_response = false;

                if self.current_trial >= self.trial_n && self.current_block > self.block_n
                    self.fig.str.String = 'Experiment end';
                    self.fig.str.Color = 'white';
                elseif self.current_trial == 1 && self.current_block <= self.block_n
                    self.fig.str.String = 'Please wait';
                    self.fig.str.Color = 'white';
                end
            elseif self.data.count == self.state.rest
                self.daq.NS.sendCommand(1);
                beep;
                self.fig.str.String = '';
                self.fig.str.Color = 'white';
            elseif self.data.count == self.state.fixation
                self.daq.NS.sendCommand(1);
                self.fig.str.String = '+';
                self.fig.str.Color = 'white';
            elseif self.data.count == self.state.stimulus
                if self.current_trial <= self.trial_n
                    trial_type = self.trial_sequence(self.current_trial);
                    if trial_type == 1
                        self.daq.NS.sendCommand(2); % DAQ command for Go trial
                        self.fig.str.String = char(9816);
                        self.fig.str.FontName = 'Arial Unicode MS';
                        self.fig.str.Color = 'green';
                    else
                        self.daq.NS.sendCommand(3); % DAQ command for No-Go trial
                        self.fig.str.String = char(9836);
                        self.fig.str.FontName = 'Arial Unicode MS';
                        self.fig.str.Color = 'red';
                    end
                end
            elseif self.data.count == self.state.response
                self.fig.str.String = '';
                self.fig.str.Color = 'white';
            elseif self.data.count == self.state.feedback
                % Determine feedback at the end of response window
                trial_type = self.trial_sequence(self.current_trial);

                if self.detected_response
                    if trial_type == 1
                        self.feedback_type = 1; % Positive for Go trial
                    else
                        self.feedback_type = 0; % Negative for No-Go trial
                    end
                else
                    if trial_type == 1
                        self.feedback_type = 0; % Negative for Go trial
                    else
                        self.feedback_type = 1; % Positive for No-Go trial
                    end
                end

                % Show feedback
                if self.feedback_type == 1
                    self.fig.str.String = 'Well done!';
                    self.fig.str.Color = 'white';
                    self.daq.NS.sendCommand(4); % DAQ command for positive feedback
                else
                    self.fig.str.String = 'Wrong!';
                    self.fig.str.Color = 'white';
                    self.daq.NS.sendCommand(1);
                end
            elseif self.data.count == self.state.end
                self.fig.str.String = '';
            end
        end
    end
end
