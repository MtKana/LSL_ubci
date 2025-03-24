classdef topogr
    properties
        para
    end
    
    methods (Access = public)
        function out = topogr(ch_rep)
            % drawTopo(Z,ch_rep)
            if numel(ch_rep) > 79
                setParameter_topo;
            else
                setParameter_topo_2;
            end
            list_var = who;
            list_var(contains(list_var,'out')) = [];
            
            out.para = Atom_iwm.generateStruct(list_var,2);
        end
        
        function Zi= generateCdata(out,Z)
            loc     = out.para.loc;
            mname   = out.para.mname;
            xi      = out.para.xi;
            yi      = out.para.yi;
            
            Z(isnan(Z)) = nanmedian(Z);
            Z = squeeze(Z);
            
            [Xi,Yi,Zi]  = griddata(loc(:,1),loc(:,2),Z,xi,yi',mname);
            %hs = imagesc(Xi(1,:),Yi(:,1),Zi);
        end
    end
end