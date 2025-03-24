function l = plotVert(h1)
yl = ylim;
hold on;
l = plot([h1 h1],[yl(1) yl(2)],'LineWidth',1.5,'Color','k');
ylim(yl);
end