classdef EEGLAButils
    properties
    end
    
    methods (Static)
        function ev        = EEGLAB_genEvt(in)
            num_din   = size(in,2);
            ev        = cell(num_din,2);
            ev        = in([2,1],:)';
        end
        
        function import(flag_path)
            if nargin < 1
                flag_path = 1;
            end
            
            switch flag_path
                case 1 %reset
                    tmp = path;
                    t   = [0,find(tmp == ':')];
                    for i_t = 1 : numel(t)-1
                        
                        tmp1=tmp(t(i_t)+1:t(i_t+1)-1);
                        
                        if ~contains(tmp1,'eeglab')
                            continue
                        else
                            rmpath(tmp1)
                            fprintf('%s removed from path\n',tmp1);
                        end
                    end
                case 2 %set
                    path_eeglab = '/Users/student/Documents/github/TopoGAN/preproc/eeglab2021.0';
                    addpath(path_eeglab);
            end
        end
        
        function EEG = EEGLAB_setEEG(EEGvar,Name, fs, path_ch,dest)
            % setEEG(EEGvar,Name, fs, path_ch,dest)
            % EEGVar like [ch, time]
            % Name like '0pre_subG'
            % fs like 200
            
            if ~exist('path_ch','var')
                p       = fileparts(mfilename('fullpath'));
                path_ch = fullfile(p,'GSN129.sfp');
            end
            
            if ~exist('dest','var')
                flag_save = 0;
            else
                flag_save = 1;
            end
            
            EEG = pop_importdata('dataformat','array','nbchan',0,'data',EEGvar,'setname',Name,...
                'srate',fs,'pnts',0,'xmin',0,'chanlocs',path_ch);
            
            if flag_save == 1
                EEG = eeg_checkset( EEG );
                EEG = pop_saveset( EEG, 'filename',[Name,'.set'],'filepath',dest);
                EEG = eeg_checkset( EEG );
            end
            
        end

        function EEG =EEGLAB_setEEG_epoch(EEGvar,Name, fs, path_ch,dest)
             if ~exist('path_ch','var')
                p       = fileparts(mfilename('fullpath'));
                path_ch = fullfile(p,'GSN129.sfp');
            end
            
            if ~exist('dest','var')
                flag_save = 0;
            else
                flag_save = 1;
            end


            EEG = pop_importdata('dataformat','array', ...
                'nbchan',0,'data',EEGvar, ...
                'setname',Name, ...
                'srate',fs,'pnts',size(EEGvar,1), ...
                'xmin',0,'chanlocs',path_ch);

            if flag_save == 1
                EEG = eeg_checkset( EEG );
                EEG = pop_saveset( EEG, 'filename',[Name,'.set'],'filepath',dest);
                EEG = eeg_checkset( EEG );
            end

        end
        
        function DINEvents_aligned = alignDIN(in_EGI,in_EEGLAB)
            %%% sortDirection: EGI->EEGLAB
            %%% out.DinEvents,EEG.event
            DINEvents_aligned = cell(size(in_EGI,1),numel(in_EEGLAB));
            FirstDIN_EEGLAB = in_EEGLAB(1).type;
            idx_first = find(contains(in_EGI(1,:),FirstDIN_EEGLAB),1,'first');
            in_EGI    = in_EGI(:,idx_first:idx_first+numel(in_EEGLAB)-1);
            for i_din = 1 : numel(in_EEGLAB)
                DINEvents_aligned{1,i_din} = in_EEGLAB(i_din).type;
                DINEvents_aligned{2,i_din} = ceil(in_EEGLAB(i_din).latency);
                DINEvents_aligned{3,i_din} = 1;
                DINEvents_aligned{4,i_din} = ceil(in_EEGLAB(i_din).latency);
            end 
        end
    end
    
    methods (Static)
        function EEG    = setEEG(S,Fs_ds,path_out,para_config)
            sessID = sprintf('Exp%02d_sub%02d_session%02d',para_config);
            fprintf('%s Begin \n',sessID);
            
            fname_EEG = fieldnames(S);
            
            %%% generateDataset
            EEGvar    = double(S.(fname_EEG{1}));
            try
                Fs        = S.(fname_EEG{contains(fname_EEG,'EEGSamplingRate')==1});
            catch
                Fs = 1000;
            end
            EEG       = EEGLAButils.EEGLAB_setEEG(EEGvar,sessID, Fs);
            
            %%% importDIN
            DINEvt    = S.(fname_EEG{contains(fname_EEG,'evt')==1});
            ev        = EEGLAButils.EEGLAB_genEvt(DINEvt);
            EEG       = pop_importevent(EEG, 'event',ev,'fields',{'latency';'type'},'skipline',1,'timeunit',0.001);
            
            %%% BPF
            EEG = pop_eegfiltnew(EEG,49,51,[],1); %Notch
            EEG = pop_eegfiltnew(EEG,1,Fs_ds/2);
            %EEG = pop_eegfiltnew(EEG,1,45);
            %     try
            %         EEG = pop_select(EEG,'time',[EEG.event(1).init_time-0.5 EEG.event(end).init_time+5]);
            %     catch
            %         EEG = pop_select(EEG,'time',[EEG.event(1).init_time-0.5 EEG.event(end).init_time+0.5]);
            %     end
            
            %%% downSampling (Pre-PreProc)
            EEG = pop_resample(EEG,Fs_ds);
            
            %%% saveData
            EEG = eeg_checkset( EEG );
            EEG = pop_saveset( EEG, 'filename',[sessID,'.set'],'filepath',path_out);
            EEG = eeg_checkset( EEG );
            
            home
            fprintf('%s Done\n',sessID);
        end
        
        function preprocData_EEGLAB(path_file,DINconfig,para_config,path_dest,list_preproc)
            num_proc = 2;
            if nargin < 5
                list_preproc = ones(num_proc,1);
            end
            %%% setpara
            sessID = sprintf('Exp%02d_sub%02d_session%02d',para_config);
            fprintf('%s Begin \n',sessID);
            
            [path_dir,filename,ext] = fileparts(path_file);
            
            EEG = pop_loadset('filename',[filename,ext],'filepath',path_dir);
            EEG.urchanlocs = EEG.chanlocs;
            
            %%% cleanEEG
            if list_preproc(1)
                EEG = clean_artifacts(EEG,'BurstCriterion','off','Highpass','off','WindowCriterionTolerances','off');
                EEG = pop_interp(EEG,EEG.urchanlocs);
                try
                    EEG = clean_artifacts(EEG,'BurstCriterion',20,'Highpass','off','ChannelCriterion','off','LineNoiseCriterion','off','WindowCriterion','off');
                catch
                    fprintf('ASR failed\n');
                end
                EEG = pop_reref(EEG,[]);
            end
            
            %%% Epoching
            num_din  = DINconfig.num_din;
            tbl_din  = DINconfig.tbl_din;
            list_DIN = cell(num_din,1);
            for i_din= 1 : num_din
                list_DIN{i_din} = sprintf('DIN%d',tbl_din(i_din));
            end
            seg_list      = tbl_din(:,[2,3]);
            seg_list(:,1) = -1 * seg_list(:,1);
            
            EEG = pop_epoch(EEG,list_DIN,seg_list(1,:));
            
            if list_preproc(2)
                %%% ICA
                tmpdir = ['./amicatemp/',datenow];
                mkdir(tmpdir);
                %[weights,sphere,mods]=runamica15(EEG.data,'outdir',tmpdir);
                [weights,sphere,mods]=runamica15(EEG.data,'outdir',tmpdir,'num_models',3);
                rmdir(tmpdir,'s')
                EEG.icaweights=weights;
                EEG.icasphere=sphere;
                EEG.icaact=[];
                EEG.icawinv=[];
                
                EEG = eeg_checkset(EEG);
                eeglab redraw;
                
                %%% ICALabel
                EEG = iclabel(EEG);
                EEG = pop_icflag(EEG,[0 0.01;0.75 1;0.6 1;0.75 1;0.75 1;0.6 1;0 0]);
                EEG = pop_subcomp(EEG,[]);
                
                eeglab redraw;
            end
            
            %%% saveData
            EEG = eeg_checkset(EEG);
            EEG = pop_saveset(EEG,'filename',[sessID,'.set'],'filepath',path_dest);
            EEG = eeg_checkset(EEG);
            
            home
            fprintf('%s Done \n',sessID);
        end
    end
    
    methods (Access = public)
        function out = EEGLAButils
            
        end
    end
end