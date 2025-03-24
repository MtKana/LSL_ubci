%%% Author: Seitaro Iwama 
%%% 2021.3
%#ok<*PROP>
%#ok<*PROPLC>
classdef visualize_data < Atom
    properties
       Font_def 
       flag_box    
       para_col
       invs
    end
    
    methods (Static)
        %% plotData
        
        plotLine(data,t,colN,linw)
        plotMat(tmpPow,cole,fs,al)
        plotMat_t(t,tmpPow,cole,al)
        plotMat_l(t,tmpPow,cole,al)
        plotMat_SE(tmpPow,cole,fs)
        l = plotVert(h1)
        h = histogram(in,col,flag_norm,num_bin)
        
        [mdl,a] = testCorr(x,y,flag_s,col,flag_scatter)
        
        function  a = modmodel(a,col)            
            a(2).Color = col;
            a(3).Color = col;
            a(4).Color = col;
        end
       
        function k = get_num_column_subplot(num_ch)
            k = factor(round(num_ch,-1));
            k(k==max(k)) = [];
            k = prod(k);
        end
    end
    
    methods (Static)
        %% FigUtils
        function f = fig(invs)
            if nargin < 1
                invs = 0;
            end
            if invs
                f = figure('visible','off');
            else
                f = figure;
            end
            hold on;
            set(f,'color',[1 1 1])
            visualize_data.setCorner;
            drawnow;pause(0.1);
        end
        function f = fig_square(invs)
            if nargin < 1
                invs = 0;
            end
            f = visualize_data.fig(invs);
            pbaspect([1 1 1]);
            visualize_data.setPos([1,1,560 420]);
            drawnow;pause(0.1);
        end
        function f = figure(invs)
            if nargin < 1
                invs = 0;
            end
            if invs
                f = figure('visible','off');
            else
                f = figure;
            end
            set(f,'color',[1 1 1])
            visualize_data.setCorner;
            drawnow;pause(0.1);
        end
        function f = figure_square(invs)
            if nargin < 1
                invs = 0;
            end
            if invs
                f = figure('visible','off');
            else
                f = figure;
            end
            pbaspect([1 1 1]);
            visualize_data.setCorner;
            drawnow;pause(0.1);
        end
        function setFigName(str)
            f = gcf;
            set(f,'Name',str); 
        end
        function t = setTitle(str)
            f = gcf;
            t = title(str,'Interpreter','none');
        end
        function setSquare
            pbaspect([1 1 1]);
        end
        formatlist = saveGCF(str,format)
        setPos(num_case,varargin)
        
        function setPos_ppt(num_case)
            if ~exist('num_case','var')
                num_case = 2;
            elseif isempty(num_case)
                num_case = 2;
            end
            try
                switch num_case
                    case 1
                        %%% 1 up
                        set(gcf,'Position',[1  1   814   380]);
                    case 2
                        %%% 2 up
                        set(gcf,'Position',[1   1  440 380]);
                    case 3
                        %%% 2 up (trim)
                        set(gcf,'Position',[1   1  500 380]);
                end
            catch
                set(gcf,'Position',num_case);
            end
        end

        function stackFig
            f1  = gcf;
            pos = get(f1,'position');
            if f1.Number > 1
                pos2  = get(figure(f1.Number-1),'position');
                pos3  = [pos(1), pos2(2)+pos2(3), pos(3), pos(4)];
                set(f1,'Position',pos3)
            end
        end
        
        function poslist = getPosList(x_start,y_start,sz_x,sz_y)
            %%todo
        end

        function setLabel(x,y,z)
            num_label = nargin;
            
            for i_label = 1 : num_label
                if i_label == 1
                    xlabel(x,'Interpreter','none')
                elseif i_label == 2
                    ylabel(y,'Interpreter','none')
                elseif i_label == 3
                    zlabel(z,'Interpreter','none')
                end
            end
            
        end

        function str = cleanName(str,flag_inv)
            if nargin < 2
                str(isspace(str))     = '_';
                str(strfind(str,'-')) = '_';
                str(strfind(str,':')) = '_';
                str(strfind(str,'/')) = '_';
            else
                if flag_inv == 99
                    str(strfind(str,'_')) = '-';
                else
                    str(strfind(str,'_')) = ' ';
                end
            end
        end

        function offLegend(h)
            hAnnotation = get(h,'Annotation');
            hLegendEntry = get(hAnnotation,'LegendInformation');
            set(hLegendEntry,'IconDisplayStyle','off')
        end

        function spout = sp(l,m,n,o)
            l = ceil(l);
            if nargin < 4
                o = 0;
            end
            spout=subplot(l,m,n);
            if o==0
                hold on;
            end
        end

        function col = monoColor(in,n,s)
        if nargin < 1
            in = 1;
        end
        if nargin < 2
            n = 128;
        end
        if nargin < 3
            s = -0.5;
        end
        col = repmat(logspace(s,1,n)/10,[3,1])';
        in = 1-in;
        col = col .*in';
        col = 1-col;
        end

        function col = genGray(num_plot)
            % col = repmat( linspace(0,0.8,num_plot),[3,1]);
            col = repmat(linspace(0.6,0.2,num_plot),[3,1]);
        end

        function col = genGrad(col,num_plot,startR)
            if ~exist('startR','var')
                startR  =1;
            end
            if size(col,1) < size(col,2)
                col = col';
            end
            tbl_col = zeros(3,num_plot);
            for i_dim = 1 : 3
                tbl_col(i_dim,:) = linspace(min(startR,col(i_dim,1)*2),col(i_dim,1),num_plot);
            end
            col = tbl_col;
        end

        function col = genGrad_ln(col,num_plot,startR)
            if ~exist('startR','var')
                startR  =1;
            end
            if size(col,1) < size(col,2)
                col = col';
            end
            tbl_col = zeros(3,num_plot);
            for i_dim = 1 : 3
                tbl_col(i_dim,:) = linspace(min(startR,col(i_dim,1)*2),col(i_dim,1),num_plot);
            end
            col = tbl_col;
        end

        function setColorOrder_gray(num_plot,f)
            col = visualize_data.genGray(num_plot);
            if nargin < 2
                f = gcf;
            end
            colororder(f,col');
        end

        function setColorOrder(f,ch)
            vi = visualize_data;
            vi = vi.loadColor;
            if nargin < 1
                f = gcf;
            end
            if ch == 2
                COL=[vi.para_col.col(:,1:2)]';
            else
                COL=[vi.para_col.col(:,1:2),vi.para_col.col4]';
            end
            colororder(f,COL);
        end

        function setCorner
            poslist = [560 420;560 725;2560 725];
            pl = get(groot,'MonitorPositions'); 
            global isteamviewer
            if isteamviewer
                pl = pl(1,:);
            else
                pl = pl(end,:);
            end
            visualize_data.setPos([pl(1),pl(2),poslist(1,1) poslist(1,2)]);
        end

        function sendAllFig
            num_fig = get(gcf,'Number');
            for i_fig = 1 : num_fig
                figure(i_fig);
                fcn_sendFig;
            end
        end

        function rotateFig
            [caz,cel] = view;
            cazl = caz + (1:360);
            for i = 1 : numel(cazl)
                view(cazl(i),cel)
                pause(0.05)
            end
        end

        function pos = getCurrPos
            pos = get(gcf,'position');
            fprintf('%d %d %d %d\n',pos)
        end

        function lm = equalizeAx
            yl = ylim;
            xl = xlim;
            lm = [min(yl(1),xl(1)),max(yl(2),xl(2))];
            xlim(lm); ylim(lm);
        end

        function chgRenderer(num_fig)
            if nargin < 1
                num_fig = get(gcf,'Number');
                s_fig = 1;
            else
                s_fig = num_fig;
            end
            for i_fig = s_fig : num_fig
                f = figure(i_fig);
                set(f,'Renderer','painters');
            end
        end

        num_fig = saveAllfigure(name_figure,format,invs)
        a = moduBoxplot(a,pointsz,colorMat)
    end
    
    methods (Access = public)   
        plot(self,t,data)
        setFig(visualize_data,num_case,size_font)
        
        function f = fcn_drawTF(visualize_data,in,x,y,flag_nonfig)
            if nargin == 5
                f = [];
            else
            f = figure;
            end
            imagesc(x,y,in);
            hold on;
            visualize_data.setFig(2,10);
            visualize_data.setCB(1,10,100);
        end

         function lin = pairwiseplot(self,in,col,width)
            if nargin < 3
                col = self.para_col.col4;
            end

            if ~exist('width','var')
                width = 1.5;
            end

            num_pair = size(in,1);
            lin = cell(num_pair,2);
            k = 72;
            for i_plot = 1 : num_pair
                l = plot([1,2],in(i_plot,:),"Color","K","LineWidth",width);
                try
                    s = scatter([1,2],in(i_plot,:),k,col(:,i_plot)','filled');
                catch
                    s = scatter([1,2],in(i_plot,:),k,col(:,1)','filled');
                end
                lin{i_plot,1} = l;
                lin{i_plot,2} = s;
            end
         end

    end
    
    methods (Static)
        %% colorbar
        cb = setCB(num_case,size_font,N)
        l = plotGrid(row,column,slide,lw)
        
    end
    
    methods (Access = public)        
        function out = loadColor(out)
            colorPalette;
            list_var = who;
            list_var(contains(list_var,'out')) = [];
            out.para_col = Atom_iwm.generateStruct(list_var,2);            
        end
        %% initilaize
        function out = visualize_data(invs,Font_def)
            if nargin < 1
                invs = 0;
            end
            if nargin < 2
                Font_def = 'Arial';
            end
            set(groot,'defaultAxesFontName',Font_def);
            set(groot,'defaultTextFontName',    Font_def);
            set(groot,'defaultLegendFontName',  Font_def);
            set(groot,'defaultColorbarFontName',Font_def);
            out.Font_def = Font_def;
            
            out      = out.loadColor;
            out.invs = invs;
            out.flag_box = 0;
        end
    end
    
    %% EEG
    methods (Access=public)
        drawTF_wavelet(vi,tbl_ERSP,frq_list,fs)
        tmp = drawTF(vi,tbl_ERSP,coi,ovrlp,num_run,flag_mm)
    end

    methods(Static)
        [cls chs,hs]=drawTopo(Z,ch_rep,coi_rep,i)
    end
end

