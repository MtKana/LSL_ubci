classdef ReceiverUDP < handle

    properties
        receiver
        config = struct;
        data_recv = [];
    end

    methods (Access = public)
        function self = ReceiverUDP()

        end

        function set_config(self, num_port_receive, num_host_receive, duration_timeout)
            self.config.num_port_receive = num_port_receive;
            self.config.num_host_receive = num_host_receive;
            self.config.duration_timeout = duration_timeout;
        end


        function start(self) % "127.0.0.1"
            self.receiver = udpport("IPV4", ...
                'LocalHost',self.config.num_host_receive, ...
                'LocalPort',self.config.num_port_receive, ...
                'Timeout',self.config.duration_timeout);
        end

        function read(self)
            self.data_recv = self.receiver.read(20,"string");
            self.receiver.flush();
        end

        function data_recv = get_data_recv(self)
            data_recv = self.data_recv;
        end
    end

end