%% routine for topo
% topography(Z,loc,3);% 引数は[129chのデータ, 電極座標, 補完の仕方]
% function routine_topo(
function [cls chs,hs]=drawTopo(Z,ch_rep,coi_rep,i)
if nargin <4
    i = 2;
end
% drawTopo(Z,ch_rep)
% if numel(ch_rep) > 82
% setParameter_topo_3;
if numel(ch_rep) > 79
    setParameter_topo;
else
    setParameter_topo_2;
end

Z(isnan(Z)) = nanmean(Z);
Z = squeeze(Z);
[Xi,Yi,Zi]  = griddata(loc(:,1),loc(:,2),Z,xi,yi',mname);
% figure;
% surf(Xi(1,:),Yi(:,1),Zi);
% uiwait(gcf);
mask    =   (sqrt((Xi-0.5).^2+(Yi-0.5).^2) <= RMAX); % 0or1
ii      =   find( mask ~= 0 );

COLORMAP=jet;
map=COLORMAP;
colormap(map);

hs=imagesc(Xi(1,:),Yi(:,1),Zi);
set(gca,'YDir','normal'); % axis xy;
daspect([1 1 1])  
axis([-VIEW_MARGIN 1+VIEW_MARGIN -VIEW_MARGIN 1+VIEW_MARGIN]);
hold on;

patch(filly,fillx,ones(size(filly)),BACKCOLOR,'edgecolor','none');
[cls chs] = contour(Xi,Yi,Zi,CONTOURNUM,'k');

ringh   = patch(headx,heady,ones(size(headx)),HEADCOLOR,'edgecolor',HEADCOLOR);
hold on

h           = plot3(loc(:,1),loc(:,2),2.5*ones(size(loc(:,2))),...
    'LineStyle','none','LineWidth',1,'Marker','o',...
    'MarkerEdgeColor','k','MarkerfaceColor','k', 'MarkerSize',i);%TODO
% h           = plot3(loc(ch_rep_a,1),loc(ch_rep_a,2),2.5*ones(size(loc(ch_rep_a,2))),...
%     'LineStyle','none','LineWidth',1,'Marker','o',...
%     'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerfaceColor',[0.9 0.9 0.9], 'MarkerSize',5);%for hot
% h2           = plot3(loc(elect_rep,1),loc(elect_rep,2),2.5*ones(size(loc(elect_rep,2))),...
%     'LineStyle','none','LineWidth',1,'Marker','o',...
%     'MarkerEdgeColor','r','MarkerfaceColor','r', 'MarkerSize',5);%for hot
hold on
try
    % h_roi       = plot3(loc(ch_rep(coi_rep),1),loc(ch_rep(coi_rep),2),2.5*ones(size(loc(ch_rep(coi_rep),2))),...
    %     'LineStyle','none','LineWidth',1,'Marker','x',...
    %     'MarkerEdgeColor','r','MarkerfaceColor','r', 'MarkerSize',2);
    h_roi       = plot3(loc(coi_rep,1),loc(coi_rep,2),2.5*ones(size(loc(coi_rep,2))),...
        'LineStyle','none','LineWidth',1,'Marker','x',...
        'MarkerEdgeColor','w','MarkerfaceColor','w', 'MarkerSize',18);
    
catch
    %     fprintf('noROI\n');
end
plot3(  NoseX,NoseY, 2*ones(size(NoseY)),'Color',HEADCOLOR,'LineWidth',HLINEWIDTH); % plot nose
plot3(   EarX, EarY, 2*ones(size(EarX)), 'Color',HEADCOLOR,'LineWidth',HLINEWIDTH); % plot left ear
plot3(-EarX+1, EarY, 2*ones(size(EarY)), 'Color',HEADCOLOR,'LineWidth',HLINEWIDTH); % plot right ear


hold off
axis off
set(gcf,'Color','w');% background:white
end