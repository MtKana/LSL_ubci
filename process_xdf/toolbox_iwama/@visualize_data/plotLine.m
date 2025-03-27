function plotLine(data,t,colN,linw)
if nargin < 2 || isempty(t)
    t = 1 : size(data,1);
end
if nargin < 4
    linw = 1.5;
end
if nargin < 3
    plot(t,data,'LineWidth',linw,'Color','k');
elseif isempty(colN)
    plot(t,data,'LineWidth',linw,'Color','k');
elseif sum(size(colN)>1) == 2 || numel(colN) == 3
    %%% arbitraryCol
    for i_lin = 1 : size(data,2)
        try
            plot(t,data(:,i_lin),'LineWidth',linw,'Color',colN(:,i_lin));
        catch
            plot(t,data(:,i_lin),'LineWidth',linw,'Color',colN(:,1));
        end
    end
elseif numel(colN) > 0
    colorPalette;
    if colN > 0
        idx = mod(colN,size(col,2));
    else
        idx = mod(abs(colN),size(col4,2));
        col = col4;
    end
    idx(idx==0) = 1;
    for i_lin = 1 : size(data,2)
        plot(t,data(:,i_lin),'LineWidth',linw,'Color',col(:,idx(i_lin)));
    end
end
end