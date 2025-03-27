
function [FOI,legend_band] = findFOI(mean_ERSP_coi,range_task,flag_minmax)
if nargin < 3
    flag_minmax = 1;
end
%% setPara
pre         = mean_ERSP_coi;
legend_band = {'Alpha';'Beta'};
bin_alpha   = 2;
bin_beta    = 2;
width_alpha = 3;
width_beta  = 3;
range_alpha = 8 :13;
range_beta  = 14 : 30;
num_alpha   = numel(range_alpha)-bin_alpha;
num_beta    = numel(range_beta)-bin_beta;

if ~exist('range_task','var')
% range_task = [21:110,200:290];
range_task = [11:80,191:260];
end

alpha(1:num_alpha) = 0;
for i_alpha = 1 : num_alpha
    alpha(i_alpha) = nanmean(nanmean(pre(range_alpha(i_alpha):range_alpha(i_alpha+2),range_task),2),1);
end

beta(1:num_beta) = 0;
for i_beta = 1 : num_beta
    beta(i_beta) = nanmean(nanmean(pre(range_beta(i_beta):range_beta(i_beta+2),range_task),2),1);
end

switch flag_minmax
    case 1 %min
        [max_alpha, index_alpha] = min(alpha);
        [max_beta, index_beta]   = min(beta);
    case 2 %max
        [max_alpha, index_alpha] = max(alpha);
        [max_beta, index_beta]   = max(beta);
end
FOI_alpha   = [range_alpha(index_alpha), range_alpha(index_alpha+2)];
FOI_beta    = [range_beta(index_beta), range_beta(index_beta+2)];

FOI = [FOI_alpha;FOI_beta];
num_band = size(FOI,1);
end
