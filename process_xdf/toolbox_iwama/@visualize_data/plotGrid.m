function l = plotGrid(row,column,slide,lw)
if nargin < 3
    slide = 0;
end
if nargin < 4
    lw = 1.5;
end

xl = xlim;
yl = ylim;
iter_row    = row + 1;
iter_column = column + 1;
l           = [];
row = row + yl(1);
column = column + xl(1);
for j_c = 1 : iter_row
    i_c = yl(1)+j_c;
    l = [l,plot([0 column+slide],[i_c-slide i_c-slide],'LineWidth',lw,'Color','k')];
end

for j_r = 1 : iter_column
    i_r = xl(1)+j_r;
    l = [l,plot([i_r-slide i_r-slide],[0-slide row+slide],'LineWidth',lw,'Color','k')];
end

end