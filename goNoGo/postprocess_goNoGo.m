%% preprocess for BMI (EGI)
function [results, user_data] = postprocess_goNoGo(stream_data_struct_array, user_data)
    results = [];

    %% main process
    if ~isempty(stream_data_struct_array(1).time_series)
%         results(1).time_series = stream_data_struct_array(1).time_series;
%         results(1).time_stamps = stream_data_struct_array(1).time_stamps;

        %% EGI NetAmp 0 (1)
        user_data.LSL_DAQ_goNoGo = user_data.LSL_DAQ_goNoGo.process_daq(stream_data_struct_array(1).time_series');%[samp ch]
        user_data.LSL_DAQ_goNoGo = user_data.LSL_DAQ_goNoGo.time_keeper;    
        user_data.LSL_DAQ_goNoGo = user_data.LSL_DAQ_goNoGo.show_protocol;
    end
end
