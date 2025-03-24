function path_file = vs(name_m)
if nargin < 1
    path_file = cd;%uigetfile('*.m');
else
    if contains(name_m,'/')
        path_file = name_m;
    elseif contains(name_m,'.m')
        path_file = fullfile(cd,name_m);
    else
        path_file = fullfile(cd,[name_m,'.m']);
    end
end
com = sprintf('/usr/local/bin/code -n %s',path_file);
system(com);
end