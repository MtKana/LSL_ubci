classdef Atom_iwm
    properties
        
    end
    
    methods(Static, Access = public)
        
        function num_nan = countnan(in)
            num_nan = sum(isnan(in),'all');
            fprintf('numel: %d, nan : %d\n',numel(in),num_nan)
        end
        function out = size_mod(in)
            out = size(in);
            out(out==1) = [];
            if isempty(out)
                out = 1;
            end
        end
        
        function out = mod_mod(x,y)
            out = mod(x,y);
            out(out==0) = y;
        end
        
    end
    
    methods(Static)
        function in2 = movefile(in1,in2)
            try
                movefile(in1,in2);
            catch
                
            end
        end
        function deleteFig(figpath)
            path_trash = '~/Documents/MATLAB/trashfile';
            Atom_iwm.mkdir_chk(path_trash);
            path_trash = fullfile(path_trash,['figtrash_',Atom_iwm.datenow(3)]);
            Atom_iwm.mkdir_chk(path_trash);
            if nargin < 1
                Atom_iwm.movefile('*.fig',path_trash);
                Atom_iwm.movefile('*.jpg',path_trash);
                Atom_iwm.movefile('*.pdf',path_trash);
            else
                Atom_iwm.movefile(figpath,path_trash);
            end
        end
        function out = dyncat(n,varargin)
            i  = 0;
            sz = cellfun(@size,varargin,'UniformOutput',false);
            num= max(cellfun(@numel,sz)) + 1;
            sz = cat(num,sz{:});
            
            szmax = max(sz,[],num);
            num_in = numel(varargin);
            szmax(szmax==1) = [];
            out = NaN([szmax,num_in]);
            
            for i_var = 1 : num_in
                tmp         = varargin{i_var};
                if numel(size_rmzero(tmp)) == 2
                    out(1:size(tmp,1),1:size(tmp,2),i_var) = tmp;
                elseif numel(size_rmzero(tmp)) == 3
                    out(1:size(tmp,1),1:size(tmp,2),1:size(tmp,3),i_var) = tmp;
                elseif numel(size_rmzero(tmp)) == 4
                    out(1:size(tmp,1),1:size(tmp,2),...
                        1:size(tmp,3),1:size(tmp,4),i_var) = tmp;
                elseif numel(size_rmzero(tmp)) == 5
                    out(1:size(tmp,1),1:size(tmp,2),...
                        1:size(tmp,3),1:size(tmp,4),1:size(tmp,5),...
                        i_var) = tmp;
                elseif numel(size_rmzero(tmp)) == 1
                    sz  = size(tmp);
                    i   = find(sz~=1);
                    out(1:size(tmp,i),i_var) = tmp;
                elseif numel(size_rmzero(tmp)) == 0
                    out(1:numel(tmp),i_var) = tmp;
                else
                    fprintf('this function is not compatible with the form\n');
                    return
                end
            end
            
            function sz = size_rmzero(in)
                sz = size(in);
                sz(sz ==1) = [];
            end
        end
        
    end
    methods(Static)
        %% staticFunctions
        function d_out = calc_cohen_d_2(a,b)
            mean1 = mean(a);
            mean2 = mean(b);
            sigma1 = std(a);
            sigma2 = std(b);
            d_out = (mean1-mean2) / sqrt((sigma1 ^2 +sigma2^2)/2);
            fprintf('d = %0.3f\n',d_out);
        end
        function str = printCorr(r,p)
            str = sprintf('r = %0.3f, p = %0.3f',r,p);
        end
        function str = datenow(grade)
            if nargin < 1
                grade = 1;
            end
            switch grade
                case 1
                    str = datestr(now,'yyyymmdd_HHMMSS');
                case 2
                    str = datestr(now,'yyyymmdd_HHMM');
                case 3
                    str = datestr(now,'yyyymmdd');
                otherwise
                    str = datestr(now,'yyyymmdd_HHMMSS');
            end
        end
        
        function str = cleanName(str,flag_inv)
            if nargin < 2
                str(isspace(str))     = '_';
                str(strfind(str,'-')) = '_';
                str(strfind(str,':')) = '_';
            else
                if flag_inv == 99
                    str(strfind(str,'_')) = '-';
                else
                    str(strfind(str,'_')) = ' ';
                end
            end
        end
        
        function printcell(in)
            for i = 1 : numel(in)
                fprintf('%d: %s\n',i,in{i});
            end
        end
        
        function mat = strfind_origin(list,word)
            num_list = size(list,1);
            mat = zeros(num_list,1);
            for i_list = 1 : num_list
                if iscell(list)
                    tmp = list{i_list,1};
                else
                    tmp = list(i_list,:);
                end
                tmp = strfind(tmp,word);
                if isempty(tmp) == 1
                    continue
                else
                    mat(i_list) = tmp(end);
                end
            end
        end
        
        function list_var = rmlist(list_var,rmf);
            if nargin < 2
                rmf = 'out';
            end
            list_var(contains(list_var,rmf)) = [];
        end
        
        function out = generateStruct(varlist,flag_place)
            place_list = {'base';'caller'};
            if nargin < 2
                flag_place = 1;
            end
            out = struct;
            for i_var = 1 : numel(varlist)
                try
                    out.(varlist{i_var}) = evalin(place_list{flag_place},sprintf('%s',varlist{i_var}));
                catch
                    out.(varlist{i_var}) = [];
                end   
            end
        end
        
        function para = appendStruct(para,para2,list_para)
            % [struct2append struct_parent, list_fields]
            if nargin < 3
                list_para = fieldnames(para2);
            end
            fnames = fieldnames(para2);
            for i_var = 1 : numel(list_para)
                idx = find(contains(fnames,list_para{i_var}));
                for i_idx = 1 : numel(idx)
                    para.(fnames{idx(i_idx)}) = para2.(fnames{idx(i_idx)});
                end
            end
        end
        
        function out = calc_tval_mat(in)
            % in[test samp]
            out = zeros(size(in,1),1);
            for i_in = 1 : size(in,1)
                tmp = in(i_in,:);
                tmp(isnan(tmp)) = [];
                [~,~,~,stat] = ttest(tmp);
                out(i_in) = stat.tstat;
            end
        end
        
        function moveJPG
            movefile('*.jpg',Atom_iwm.datenow)
        end
        
        function datestr = moveFig(datestr)
            if nargin < 1
                datestr = Atom_iwm.datenow;
            end
            
            Atom_iwm.mkdir_chk(datestr);
            list_ext = {'fig','jpg','pdf'};
            for i_ext = 1 : numel(list_ext)
                path_out = fullfile(datestr,list_ext{i_ext});
                Atom.mkdir_chk(path_out);
                Atom.movefile(['*',list_ext{i_ext}],path_out);
            end
        end
    end
    
    methods (Access = public)
        function idx = transformIdx(atomFunc,in,origmat)
            sz = size(origmat);
            if numel(sz) > 2
                fprintf('sorry \n');
                return
            end
            
            idx     = zeros(numel(in),2);
            idx(:,1)  = atomFunc.mod_mod(in,sz(1));
            idx(:,2)  = ceil(in/sz(1));
        end
    end
    
    methods (Static, Access = public)
       
        
        function [in,num_in] = fullPath(in)
            in        = fullfile({in.folder},{in.name})';
            num_in    = numel(in);
        end
        
        function i_d = askDir(dirD)
            num_D  = numel(dirD);
            count_d = 0;
            record_d= [];
            for i_d = 1 : num_D
                tmp = dirD(i_d).name;
                if tmp(1) == '.'
                    continue
                else
                    count_d = count_d + 1;
                    fprintf('%d: %s\n',count_d,tmp);
                    record_d(count_d) = i_d;
                end
            end
            
            if count_d == 1
                i_d = record_d(1);
            else
                i_d = input('Which File ->');
                i_d = record_d(i_d);
            end
            
        end
        
        function out = dir_child(in)
            out = dir(in);
            out = out(~ismember({out.name}, {'.', '..'}));
            out = out([out.isdir]);
        end
        
        function mkdir_chk(path_base)
            if ~exist(path_base,'dir')
                mkdir(path_base)
            end
        end
        
        
        
        function [out,list_idx] = getPath_mat(study,type,in_path)
            switch lower(study)
                case 'bitap'
                    getpath_bitap;
            end
            list_idx        = Atom_iwm.generateStruct(who('idx*'),2);
        end
        
        function dir_out = sortdir(dir_in,inv)
            if nargin == 2
                [~,I] = sort([dir_in(:).datenum],'descend');
            else
            [~,I] = sort([dir_in(:).datenum]);
            end
            dir_out = dir_in(I);
        end
        
        
        
    end
    
    methods (Access = public)
        %% init
        function atomFunc = Atom_iwm
            
        end
        
    end
end