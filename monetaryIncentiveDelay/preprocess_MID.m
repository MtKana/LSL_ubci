%% preprocess for BMI (EGI)
function [results, user_data] = preprocess_MID(stream_data_struct_array, user_data)
    results = [];

    %% main process
    if ~isempty(stream_data_struct_array(1).time_series)
        results(1).time_series = stream_data_struct_array(1).time_series;
        results(1).time_stamps = stream_data_struct_array(1).time_stamps;

        %% EGI NetAmp 0 (1)
        user_data.LSL_EGI_MID = user_data.LSL_EGI_MID.reflesh_buffer(stream_data_struct_array(1).time_series');%[samp ch]
        user_data.LSL_EGI_MID = user_data.LSL_EGI_MID.time_keeper;    
        user_data.LSL_EGI_MID = user_data.LSL_EGI_MID.show_protocol;
    end
end
