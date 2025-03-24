function [y,scale_para] = scale_power(spectrogram,in)

if nargin == 2
    ms = in{1};
else
    ms             = abs(min(spectrogram,[],1));
end
spectrogram_db = spectrogram + ms;
spectrogram_db(spectrogram_db<0) = 0;
H = 1;
N = size(spectrogram_db,1);
y = zeros(N,H);
first_q = zeros(1,H);
third_q = zeros(1,H);
md      = zeros(1,H);
scale_k = zeros(1,H);
if nargin == 2
    scale_k = in{2};
    md      = in{3};
    for h = 1:H
        y0         = spectrogram_db;
        y(:,h)     = 1./(1+exp(-scale_k(h).*(y0-md(h))));
    end
else
    for h = 1:H
        y0         = spectrogram_db;
        first_q(h) = quantile(y0,0.25);
        third_q(h) = quantile(y0,0.75);
        scale_k(h) = 2*(log(3))/(third_q(h)-first_q(h));
        md(h)      = median(y0);
        y(:,h)     = 1./(1+exp(-scale_k(h).*(y0-md(h))));
    end
end
scale_para = {ms,scale_k,md};
end