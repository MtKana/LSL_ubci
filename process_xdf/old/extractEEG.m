% Extracts and saves the raw EEG data 
function extractAndSaveComponent(inputMatFilePath)
    % Check if the input file exists
    if ~isfile(inputMatFilePath)
        error('The specified input file does not exist.');
    end
    
    % Load the .mat file
    loadedData = load(inputMatFilePath);
    
    % Create the component name based on the input file path
    [~, fileName, ~] = fileparts(inputMatFilePath);
    componentName = [fileName, 'mff'];
    
    % Check if the specified component exists
    if ~isfield(loadedData, componentName)
        error(['The specified component ''', componentName, ''' does not exist in the input file.']);
    end
    
    % Extract the specific component
    raw_EEG = loadedData.(componentName);
    
    % Create the output file path by appending '_extracted' to the input file name
    [filePath, fileName, fileExt] = fileparts(inputMatFilePath);
    outputMatFilePath = fullfile(filePath, ['EEG_', fileName, fileExt]);
    
    % Save the extracted component in a separate .mat file with the same variable name
    save(outputMatFilePath, 'raw_EEG');
    
    % Verify by loading the newly saved file
    verifyData = load(outputMatFilePath);
    
    % Display the shape of the loaded data to verify
    disp(['Shape of ', componentName, ': ', num2str(size(verifyData.raw_EEG))]);
    disp(['Extracted component saved to: ', outputMatFilePath]);
end

extractAndSaveComponent('Block0_re_20050215_082837.mat')
extractAndSaveComponent('Block01_20050215_084433.mat')
extractAndSaveComponent('Block02_20050215_085415.mat')
extractAndSaveComponent('Block03_20050215_090214.mat')
extractAndSaveComponent('Block04_20050215_091601.mat')
extractAndSaveComponent('Block05_20050215_092505.mat')