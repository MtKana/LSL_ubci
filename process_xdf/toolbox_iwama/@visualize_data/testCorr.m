function [mdl,a] = testCorr(x,y,flag_s,col,flag_scatter)

if nargin < 3
    flag_s = 1;
end

if ~exist('col','var')
    col = 'k';
elseif isempty(col)
    col = 'k';
end

if flag_s == 1
    mdl = fitlm(x,y);
else
    mdl = fitlm(x,y,'Intercept',false);
end

if ~exist('flag_scatter','var')
    flag_scatter = 0;
elseif isempty(flag_scatter)
    flag_scatter = 0;
end

a = plot(mdl);
a(1).Marker = 'None';
a(2).LineWidth = 1.5;
a(2).Color = 'k';
a(3).Color = 'k';
a(4).Color = 'k';
a(3).LineWidth = 1.5;
a(4).LineWidth = 1.5;
a(3).LineStyle = '--';
a(4).LineStyle = '--';
arrayfun(@offLegend,a);
legend off
xlabel(' ')
ylabel(' ')
title(' ');
hold on ;
if flag_scatter == 1
    scatter(x,y,72,'filled','MarkerFaceColor',col,'MarkerEdgeColor',col);
end
end

function offLegend(h)
hAnnotation = get(h,'Annotation');
hLegendEntry = get(hAnnotation,'LegendInformation');
set(hLegendEntry,'IconDisplayStyle','off')
end