function setPos(num_case,varargin)
if ~exist('num_case','var')
    num_case = 2;
elseif isempty(num_case)
    num_case = 2;
end
szmax = get(0,'ScreenSize');
try
    switch num_case
        case 1
            %%% large
            set(gcf,'Position',szmax*0.95);
        case 2
            %%% TF,Topo
            set(gcf,'Position',[680   296   898   682]);
        case 3
            %%% middle
            set(gcf,'Position',[8 172 953 747]);
        case 4
            %%% for Presentation
            set(gcf,'Position',[680 467 1112 461]);
        case 5 %for stat vis
            set(gcf,'Position',[680 467 350 350]);
        case 'tile'
            poslist_tile = varargin{1};
            set(gcf,'Position',poslist_tile(varargin{2},:));
    end
catch
    set(gcf,'Position',num_case);
end
drawnow limitrate
end