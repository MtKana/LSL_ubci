function plot(self,t,data,idx_col)
if nargin == 4    
    if size(data,2) > 1
        col = self.para_col.col4;
    else
        if numel(idx_col) == 2
            evalin('caller',sprintf('col = self.para_col.col%d;',idx_col(1)));
            idx_col = idx_col(2);
            col = col(:,idx_col);
        else
            col = self.para_col.col(:,idx_col);
        end
    end
else
    col = self.para_col.col(:,1);
end
plot(t,data,'LineWidth',1.2,'Color',col);
end