%% postprocess
function [results, user_data] = preprocess_BMI(stream_data_struct_array, user_data)
    results = [];

    % main process
    if ~isempty(stream_data_struct_array(1).time_series)
        results(1).time_series = stream_data_struct_array(1).time_series;
        results(1).time_stamps = stream_data_struct_array(1).time_stamps;

        % LSL-EGI-1 (1)
        user_data.LSL_EGI_BMI = user_data.LSL_EGI_BMI.reflesh_buffer(stream_data_struct_array(1).time_series');%[samp ch]
        user_data.LSL_EGI_BMI = user_data.LSL_EGI_BMI.process_eeg; 
        user_data.LSL_EGI_BMI = user_data.LSL_EGI_BMI.show_protocol; 
    end
end
