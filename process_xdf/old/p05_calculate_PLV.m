sub = '00';
block = '05';

% Load the final average source current data 
load(sprintf("data/sub-%s/06_beta_bandpower/precentralL_betapower_block%s.mat", sub, block));
left_precentral_beta_power = TF;
load(sprintf("data/sub-%s/06_beta_bandpower/precentralR_betapower_block%s.mat", sub, block)); 
right_precentral_beta_power = TF; 
load(sprintf("data/sub-%s/06_beta_bandpower/SMAL_betapower_block%s.mat", sub, block)); 
left_SMA_beta_power = TF;
load(sprintf("data/sub-%s/06_beta_bandpower/SMAR_betapower_block%s.mat", sub, block)); 
right_SMA_beta_power = TF;

beta_band = [14 30]; % Hz

% Define the sampling frequency
Fs = 200; % Hz

% Design a Butterworth bandpass filter for the beta band
[nrb, nra] = butter(2, beta_band / (Fs / 2));

% Define the number of time points
N = length(left_precentral_beta_power); % Assuming both left and right have the same length

% Define the time vector
t = (0:(N-1)) / Fs;

IIRsig_left = filtfilt(nrb, nra, left_precentral_beta_power);
IIRsig_right = filtfilt(nrb, nra, right_precentral_beta_power);

% Ensure both signals are of the same length after filtering
min_length = min(length(IIRsig_left), length(IIRsig_right));
IIRsig_left = IIRsig_left(1:min_length);
IIRsig_right = IIRsig_right(1:min_length);

% Calculate the angle difference between the two signals
AngleDiff = diff(angle(hilbert([IIRsig_left(:), IIRsig_right(:)])), 1, 2);
AngleDiff = exp(1i * AngleDiff);

% Compute the Phase Locking Value (PLV)
tmp_PLV = abs(mean(AngleDiff));

% Optionally, you can store the PLV value for each time point
PLV = tmp_PLV;  % Store the PLV value

% Save the PLV value along with the beta power data
save(sprintf("data/sub-%s/08_PLV/PLV_block%s.mat", sub, block),'PLV');
