%% preprocess for BMI (Keyboard)
function [results, user_data] = preprocess_key(stream_data_struct_array, user_data)
    results = [];

    %% main process
    if ~isempty(stream_data_struct_array(1).time_series)
        results(1).time_series = stream_data_struct_array(1).time_series;
        results(1).time_stamps = stream_data_struct_array(1).time_stamps;

        %% press 'q' to start trial
        if stream_data_struct_array(1).time_series(1,1) == 113
            udpSocket = udp("127.0.0.5", 5500,'LocalPort', 0);
            fopen(udpSocket);
            fwrite(udpSocket, 'q', 'char');
            fclose(udpSocket);
            delete(udpSocket);
        end
        
        %% press 'z' to end trial
        if stream_data_struct_array(1).time_series(1,1) == 122
            inputemu('Key_up','w')
            udpSocket = udp("127.0.0.5", 5500,'LocalPort', 0);
            fopen(udpSocket);
            fwrite(udpSocket, 'z', 'char');
            fclose(udpSocket);
            delete(udpSocket);
        end

        %% press 'k' for easier threshold GO
        if stream_data_struct_array(1).time_series(1,1) == 107
            udpSocket = udp("127.0.0.5", 5500,'LocalPort', 0);
            fopen(udpSocket);
            fwrite(udpSocket, 'k', 'char');
            fclose(udpSocket);
            delete(udpSocket);
        end

        %% press 'j' for harder threshold GO
        if stream_data_struct_array(1).time_series(1,1) == 106
            udpSocket = udp("127.0.0.5", 5500,'LocalPort', 0);
            fopen(udpSocket);
            fwrite(udpSocket, 'j', 'char');
            fclose(udpSocket);
            delete(udpSocket);
        end

        %% press 'm' for harder threshold STOP
        if stream_data_struct_array(1).time_series(1,1) == 109
            udpSocket = udp("127.0.0.5", 5500,'LocalPort', 0);
            fopen(udpSocket);
            fwrite(udpSocket, 'm', 'char');
            fclose(udpSocket);
            delete(udpSocket);
        end

        %% press 'n' for easier threshold STOP
        if stream_data_struct_array(1).time_series(1,1) == 110
            udpSocket = udp("127.0.0.5", 5500,'LocalPort', 0);
            fopen(udpSocket);
            fwrite(udpSocket, 'n', 'char');
            fclose(udpSocket);
            delete(udpSocket);
        end

        %% press 'n' for easier threshold STOP
        if stream_data_struct_array(1).time_series(1,1) == 110
            udpSocket = udp("127.0.0.5", 5500,'LocalPort', 0);
            fopen(udpSocket);
            fwrite(udpSocket, 'n', 'char');
            fclose(udpSocket);
            delete(udpSocket);
        end

        %% force Stop -> Go
        if stream_data_struct_array(1).time_series(1,1) == 103
            udpSocket = udp("127.0.0.5", 5500,'LocalPort', 0);
            fopen(udpSocket);
            fwrite(udpSocket, 'g', 'char');
            fclose(udpSocket);
            delete(udpSocket);
        end

        %% force Go -> Stop
        if stream_data_struct_array(1).time_series(1,1) == 104
            udpSocket = udp("127.0.0.5", 5500,'LocalPort', 0);
            fopen(udpSocket);
            fwrite(udpSocket, 'h', 'char');
            fclose(udpSocket);
            delete(udpSocket);
        end
    end
end
