%% postprocess for BMI (DAQ)
function [results, user_data] = postprocess_resting(stream_data_struct_array, user_data)
    results = [];

    %% main process
    if ~isempty(stream_data_struct_array(1).time_series)
%         results(1).time_series = stream_data_struct_array(1).time_series;
%         results(1).time_stamps = stream_data_struct_array(1).time_stamps;

        %% LSL-DAQ-1
        user_data.LSL_DAQ_resting = user_data.LSL_DAQ_resting.time_keeper;    
        user_data.LSL_DAQ_resting = user_data.LSL_DAQ_resting.show_protocol;
        user_data.LSL_DAQ_resting = user_data.LSL_DAQ_resting.process_daq(stream_data_struct_array(1).time_series');%[samp ch]
    end
end
