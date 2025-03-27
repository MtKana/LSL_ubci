sub = '00';
block = '05';

% Load the final average source current data 
load(sprintf("data/sub-%s/04_beta_bandpower/precentralL_betapower_block%s.mat", sub, block));
left_precentral_beta_power = TF;
load(sprintf("data/sub-%s/04_beta_bandpower/precentralR_betapower_block%s.mat", sub, block)); 
right_precentral_beta_power = TF; 
load(sprintf("data/sub-%s/04_beta_bandpower/SMAL_betapower_block%s.mat", sub, block)); 
left_SMA_beta_power = TF;
load(sprintf("data/sub-%s/04_beta_bandpower/SMAR_betapower_block%s.mat", sub, block)); 
right_SMA_beta_power = TF;

SMA_beta_power = (right_SMA_beta_power + left_SMA_beta_power)/2;

% Define the rest period 
rest_start = 1;
rest_end = 1000;

% Ref(f): average power during the rest period
Ref_f = mean(SMA_beta_power(rest_start:rest_end));

% Calculate ERSP for each time point
ERSP = 100 * ((SMA_beta_power - Ref_f)/Ref_f);

% Plot ERSP
figure;
plot(ERSP);
title('ERSP of Beta Band Power at SMA');
xlabel('Time Points');
ylabel('ERSP (%)');

averaged_ERSP = mean(ERSP, 2);

disp('The average is:');
disp(averaged_ERSP);

save_filename = sprintf("data/sub-%s/05_ERSP_SMA/ERSP_SMA_block%s.mat", sub, block);
save(save_filename, "ERSP", "averaged_ERSP");