%     if ~isempty(stream_data_struct_array(1).time_series)

%% preprocess for BMI (EGI)
function [results, user_data] = preprocess_stroop(stream_data_struct_array, user_data)
    results = [];

    %% Main Process
    if ~isempty(stream_data_struct_array)

        % Store the results
        results(1).time_series = stream_data_struct_array(1).time_series;
        results(1).time_stamps = stream_data_struct_array(1).time_stamps;

        %% EGI NetAmp 0 (1)
        user_data.LSL_EGI_stroop = user_data.LSL_EGI_stroop.reflesh_buffer(stream_data_struct_array(1).time_series'); % [samp ch]
        user_data.LSL_EGI_stroop = user_data.LSL_EGI_stroop.time_keeper;
        user_data.LSL_EGI_stroop = user_data.LSL_EGI_stroop.show_protocol;
    else
        disp('[WARNING] stream_data_struct_array is empty.');
    end
end
