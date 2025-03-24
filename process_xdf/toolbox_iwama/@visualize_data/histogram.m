function h = histogram(in,col,flag_norm,num_bin)
vi = visualize_data;

if nargin < 4
    num_bin = ceil(numel(in)/10);
end
if nargin < 3
    meth_norm = 'count';
elseif flag_norm == 1
    meth_norm = 'probability';
elseif flag_norm == 2
    meth_norm = 'cdf';
else
    meth_norm = 'count';
end

if nargin < 2
    col = vi.para_col.col(:,1);
elseif numel(col) == 1
    col = vi.para_col.col(:,col);
elseif numel(col) == 2
    str1 = sprintf('col%d',col(1));
    col = vi.para_col.(str1)(:,col(2));
elseif numel(col) == 3
    col = col;
end

switch meth_norm
    case 'cdf'
        h = histogram(in,num_bin,'EdgeColor',col,'LineWidth',2,...
            'FaceColor','none','Normalization',meth_norm,'DisplayStyle','stairs');
    otherwise
        h = histogram(in,num_bin,'FaceColor',col,'Normalization',meth_norm);
end
end

