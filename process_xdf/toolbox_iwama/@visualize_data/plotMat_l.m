function plotMat_l(tmpPow,cole,fs,al)
%%
vi = visualize_data;
if ~exist('al','var')
    al = 0.2;
end
tmpPow = squeeze(tmpPow);
%%% mat: [data, trl]
if exist('cole','var') ~= 1 || isempty(cole)
    colorPalette;
    cole = col(:,1);
end

if ~exist('fs','var')
    fs = 1;
end

t2 = 1/fs : 1/fs: size(tmpPow,1)/fs;
hold on;
coleh= (cole+0.1)*1.4;
coleh(coleh>1) = 1;
for i_lin = 1 : size(tmpPow,2)
    l = plot(t2,tmpPow(:,i_lin),'Color',coleh,'LineWidth',0.3);
    vi.offLegend(l);
end
lin = plot(t2,nanmean(tmpPow,2),'Color',cole,'LineWidth',2);

end