function num_fig = saveAllfigure(name_figure,format,invs)
if nargin < 1
    name_figure = Atom_iwm.datenow;
end

if nargin < 2
    format = [1,2,4];
end

if nargin < 3
    invs = 0;
end

num_fig = get(gcf,'Number');
for i_fig = 1 : num_fig
    if invs
        f = figure(i_fig);
        f.Visible = 'off';
    else
        figure(i_fig);
    end
    str_tmp = sprintf('%s_%02d',name_figure,i_fig);
    visualize_data.saveGCF(str_tmp,format);
end

end