function formatlist = saveGCF(str,format)
%% saveGCF(str,format)
% 1: fig
% 2: pdf
% 3: tiffn
% 4: jpg
% 5: all
[~,dirname,~] = fileparts(cd);
dirname = [dirname,'_',datestr(now,'yyyymmddHHMMSS')];

if ~exist('str','var')
    str = dirname;
else
    str = visualize_data.cleanName(str);
end
if ~exist('format','var')
    format = [1,2,4];
end
formatlist = {'fig';'pdf';'tiffn';'jpg'};
num_format = numel(formatlist);

if sum(format > num_format) > 0
    format = 1 : num_format;
end

for i_format =  1 : numel(format)
    fi = formatlist{format(i_format)};
    try
        saveas(gcf,str,fi);
    catch
        saveas(gcf,dirname,fi);
    end
end
end