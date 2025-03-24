%% col_japonase
teal    = [105 176 172]/255;
orange  = [233 139 42]/255;
blue    = [58 143 183]/255;
col     = [teal;orange;blue]';

magenta = [193 50 142];
cyan    = [0 125 239];
col     = [teal;orange;blue]';
col2    = [magenta;cyan]'/255';
mb      = [49 100 154]/255;
mr      = [193 61 58]/255;
col3    = [mr;mb]';
col4    = [0	190	170;...
            64	0	130	;...
            236	156	4	;...
            15	76	129	;...
            237	102	99	;...
            255	163	114 ;...
            254	52	110	;...
            ]/255;
col4    = col4';
col5    = ([255 121 0;0 109 168]/255)';
col6    = [155	50	255;246	94	94; 21	88	18; 92	201	244;79	255	0]'/255;
col7    = [0 170 144;106 76 156;235  180 113;123 144 210; 215 84 85; 142 53 74;238 169 169]'/255;
clear teal orange blue magenta cyan mb mr
col3_b  = col3/2;
col_tr1  = [col3(:,1),col3_b(:,1)];
col_tr2  = [col3(:,2),col3_b(:,2)];
col_tr   = {col_tr1;col_tr2};



function hoge
figure;
imagesc(1:11);
colormap(col_grad')
%%
figure;
imagesc(1:7);
colormap(col7')
%%
fig;
for i = 1 : size(col7,2)
   plot(rand(10,1)+i,'LineWidth',4,'Color',col7(:,i))
end
%%
r1 = rand(100,20);
r2 = rand(100,20);

figure;
plotMat(r1,col3(:,1));
plotMat(r2,col3(:,2));
end