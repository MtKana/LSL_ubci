%%% Author: Seitaro Iwama
%%% 2021.3
%#ok<*PROP>
%#ok<*PROPLC>
classdef analysis_EEG < visualize_data & EEG_qc
    properties
        Dataname
        para
        filtPara
        spaPara
        fftPara
        signal_EEG
        signal_EEG_spafil
        impedances
        DinEvents
        Fs = 1000;
        COI
        flag_spa
        tbl_fft
        ERSP
        ERSP_topo
        FOI
        legend_band
        COI_draw
    end
    
    methods (Static, Access = private)
          function tmp = fcn_loadEEG(path,para)
            load(path);
            eeg = who('*mff');
            imp = who('Impedances*');
            din = who('evt_*');
            Fs  = who('EEGSamplingRate*');
            tmp = analysis_EEG(para);
            tmp.signal_EEG = double(eval(eeg{1,1}))';
            tmp.impedances = eval(imp{1,1});
            tmp.DinEvents  = eval(din{1,1});
            tmp.Fs         = eval(Fs{1,1});
          end 
    end
    
    methods (Static, Access = public) %Time-Frequency analysis

         function [data_EEG,data] = fftEEG(data_EEG,in)
            fprintf('fftEEG\n');
            if nargin < 2
                in = data_EEG.signal_EEG;
            end
            Fs   = data_EEG.Fs;
            in   = data_EEG.padEEG(in,Fs,Fs);
            data = fftEEG(in,Fs,data_EEG.fftPara.frq,Fs,data_EEG.fftPara.ovrlp);
            data_EEG.tbl_fft = data;
         end
         
        
        function tbl_hilbert = hilbertEEG(data,fs,FOI)
            if nargin == 3
                [bpb,bpa] = butter(3,FOI/(fs/2));
                data = filtfilt(bpb,bpa,data);
            end
            tbl_hilbert = hilbert(data);
        end
        
        function [tbl_wavelet,tbl_f] = waveletEEG(data_fil,fs,frq)
            %%% tbl_wavelet = waveletEEG(data_fil[time ch trl],fs,frq)
            fprintf('Start Wavelet transform (be cautious about memory usage) \n');
            if nargin < 3
                frq = 50;
            end
            [time,num_ch,num_trl] = size(data_fil);
            fb = cwtfilterbank('SignalLength',time,'SamplingFrequency',fs);
            tbl_wavelet = zeros(frq,time,num_ch,num_trl);
            tbl_f = zeros(frq,num_ch,num_trl);
            for i_trl = 1 : num_trl
                for i_ch = 1 : num_ch
                    [tmp,f] = cwt(data_fil(:,i_ch,i_trl),'FilterBank',fb);
                    i = find(f<=frq);
                    f = f(i);
                    tbl_wavelet(1:numel(i),:,i_ch,i_trl) =abs(tmp(i(1:end),:));
                    tbl_f(1:numel(f),i_ch,i_trl) = f;
                end
            end
            tbl_wavelet = permute(tbl_wavelet,[2,1,3,4]);
            fprintf('Finish Wavelet transform  \n');
        end
    end
    
    methods (Static)  % Utilities      
        
        function ch_rep = getCh_rep(spaPara)
            num_run = numel(spaPara);
            ch_rep = [spaPara(:).COI_spafil];
            list_ch = zeros(max(ch_rep),num_run);
            for i_run = 1 : num_run
                list_ch(spaPara(i_run).COI_spafil,i_run) = 1;
            end
            ch_rep = find(sum(list_ch,2)==num_run);
        end
        
        function in = detectOutlier(in,n)
            in = isoutlier(in,'quartiles',n);
        end
        
        function out = sortMAT(out)
            nl      = {out(:).name}';
            timeI   = Atom_iwm.strfind_origin(nl,'_');
            matI    = Atom_iwm.strfind_origin(nl,'.mat');
            num_run = numel(timeI);
            
            timestmp= zeros(num_run,1);
            for i_run = 1 : num_run
                a = nl{i_run};
                timestmp(i_run) = str2num(a(timeI(i_run)+1:matI(i_run)-1));
            end
            
            [~,idx_exp] = sort(timestmp);
            out         = out(idx_exp);
        end
        
        function para = setPara_spa(rjct_car)
            if nargin < 1
                rjct_car = [];
            end
            rjct_car = [rjct_car;36];
            %%% configured for C3 channel in EGI netstation
            COI_spafil = 36;
            SmallLap = [30 35 37 41];
            LargeLap = [13 34 54 46];
            
            CAR             = 1:129;
            CAR(rjct_car)   = [];
            
            filterlist  =  {'Default';'Small Laplacian';'Large Laplacian';'Common Average';'Masteoid';'Large Laplacian'};
            filtername  = filterlist{1};
            
            varlist     = who;
            para        = Atom_iwm.generateStruct(varlist,2);
        end
        
        function para = setPara_fft
            frq     = 50;
            ovrlp   = 0.9;            
            varlist = who;
            para    = Atom_iwm.generateStruct(varlist,2);
        end
        
        function out = cutBlank(in,time_blank)
            out = in(1:end-time_blank,:,:);
        end
        
        function out = integrateSession(in)
            fprintf('Integrate\n')
            num_run = numel(in);
            out = in(1); %template
            signal_EEG = zeros([size(out.signal_EEG),num_run]);
            rjct_car   = [];
            for i_run = 1 : num_run
                rjct_car = [rjct_car;in(i_run).spaPara.rjct_car];
                try
                    signal_EEG(:,:,:,i_run) = in(i_run).signal_EEG;
                catch
                    tmp     = in(i_run).signal_EEG;
                    num_dim = numel(size(signal_EEG));
                    cols    = repmat(':,',[1 num_dim-1]);
                    eval(sprintf('signal_EEG(%si_run) = tmp;',cols));
                end
            end
            out.signal_EEG       = signal_EEG;
            out.spaPara          = out.setPara_spa(unique(rjct_car));
        end
        
        function [eeg,sz_pad] = padEEG(eeg,Fs,sz_win)
            if numel(size(eeg))==2
                [time,num_ch] = size(eeg);
                sz_pad = sz_win/2;
                zeropad = zeros(sz_pad,num_ch);
                eeg = [zeropad;eeg;zeropad];
            elseif numel(size(eeg))==3
                [time,num_ch,num_trl] = size(eeg);
                sz_pad = sz_win/2;
                zeropad = zeros(sz_pad,num_ch,num_trl);
                eeg = [zeropad;eeg;zeropad];
            elseif numel(size(eeg))==4
                [time,num_ch,num_trl,num_run] = size(eeg);
                sz_pad = sz_win/2;
                zeropad = zeros(sz_pad,num_ch,num_trl,num_run);
                eeg = [zeropad;eeg;zeropad];
            end
        end
        
        function COI = spaPara_appendCOI(COI,COI_add,COI_rjct)
            COI_add(ismember(COI_add,COI_rjct)) = [];
            try
                COI = unique([COI,COI_add]);
            catch
                COI = unique([COI;COI_add]);
            end
        end
        
        function COI = spaPara_deleteCOI(COI,COI_rem)
            %(spaPara,COI_rem)
            %COI = spaPara.COI_spafil;
            COI(ismember(COI,COI_rem)) = [];            
            %spaPara.COI_spafil = COI;
        end
        
        function [time_DIN,name_DIN] = extractDIN(DIN)
            time_DIN = cell2mat(DIN(2,:));
            name_DIN = reshape([DIN{1,:}],4,[]);
            name_DIN = (name_DIN(end,:));
        end
        
        function out = regout(in,ref)
            out  = zeros(size(in));
            [time,ch,trl,run] = size(out);
            for i_run = 1 : run
                for i_trl = 1 : trl
                    for i_ch = 1 : ch
                        [~,~,out(:,i_ch,i_trl,i_run)] =...
                            regress(in(:,i_ch,i_trl,i_run),...
                            [ref(:,:,i_trl,i_run),ones(time,1)]);
                    end
                end
            end
        end
        
        function ref = getLap(in)
            if in == 1 %C3
                ref = [13, 34, 54, 46];
            elseif in == 2 %C4
                ref = [112 116 79 98];
            else
                S = load('Admat_4v2.mat');
                ref = find(S.tbl_ch_nearest(in,:));
            end 
        end
    end
    
    methods (Access = private) %internal proc       
        
        function time_trl = getTrialTime(data_EEG)
            para  = data_EEG(1).para;
            fname = fieldnames(para);
            time_trl = 0;
            idx_time = find(contains(fname,'time'));
            
            for i_time = 1 : numel(idx_time)
                time_trl = time_trl + para.(fname{idx_time(i_time)});
            end
        end        
    end
    
    methods (Access = public) % main
      
        function data_EEG = loadEEG(data_EEG,idx_run)
            fprintf('loadEEG\n');
            dir_EEG = data_EEG.sortMAT(dir(fullfile(data_EEG(1).para.path_EEGData,'*.mat')));
            
            if nargin == 2 
                if numel(idx_run) >= idx_run
                    dir_EEG = dir_EEG(idx_run);
                end
            end
                
            out_EEG = analysis_EEG(data_EEG(1).para);
            for i_file = 1 : numel(dir_EEG)
                tmppath         = fullfile(dir_EEG(i_file).folder,dir_EEG(i_file).name);
                out_EEG(i_file) = data_EEG.fcn_loadEEG(tmppath,data_EEG(1).para);
            end
            data_EEG = out_EEG';
        end
        
        function data_EEG = epochEEG(data_EEG)
            fprintf('epochEEG\n');
            
            time_trl   = data_EEG.getTrialTime;
            time_blank = data_EEG.para.time_blank;
            num_trl    = data_EEG.para.num_trl;
            Fs         = data_EEG.Fs;
            
            signal_EEG = data_EEG.signal_EEG;
            DinEvents  = data_EEG.DinEvents;
            Din_start  = DinEvents{2,1};
            
            signal_EEG = signal_EEG(:,Din_start+1:end);
            signal_EEG = signal_EEG(:,1:time_trl*Fs*num_trl);
            signal_EEG = reshape(signal_EEG,size(signal_EEG,1),time_trl*Fs,[]);
            signal_EEG = double(permute(signal_EEG,[2, 1, 3]));
            signal_EEG = data_EEG.cutBlank(signal_EEG,time_blank*data_EEG.Fs);
            
            data_EEG.signal_EEG     = signal_EEG;
            data_EEG.para.time_trl  = time_trl-time_blank;
        end
        
        function data_EEG = preproc(data_EEG)
            fprintf('preproc\n');
            signal_EEG = data_EEG.signal_EEG;
            signal_EEG = detrend(signal_EEG);
            signal_EEG = filtEEG(signal_EEG,data_EEG.Fs,4,1);
            data_EEG.signal_EEG = signal_EEG;
        end
        
        function data_EEG = filtfilt_IIR(data_EEG,ord,Wn)
            fprintf('filtfilt_IIR\n');
            if nargin < 2
                ord = 3;
            end
            if nargin < 3
                %Wn = [8 30];
                Wn = [3 64];
            end
            Fs = data_EEG.Fs;
            [bpb,bpa] = butter(ord,Wn/(Fs/2));
            varlist = who;
            varlist(contains(varlist,'data_EEG')) = [];
            
            data_EEG.signal_EEG = filtfilt(bpb,bpa,data_EEG.signal_EEG);
            data_EEG.filtPara   = Atom_iwm.generateStruct(varlist,2);
            
        end
        
        function data_EEG = filtfilt_Notch(data_EEG,ord,nc)
            fprintf('filtfilt_Notch\n');
            if nargin < 2
                ord = 3;
            end
            if ~exist('nc','var')
                Pow       = 50;
            else
                Pow = nc;
            end
            Wn        = [Pow-1 Pow+1];
            Fs        = data_EEG.Fs;
            [ncb,nca] = butter(ord,Wn/(Fs/2),'stop');
            varlist   = who;
            varlist(contains(varlist,'data_EEG')) = [];
            data_EEG.signal_EEG = filtfilt(ncb,nca,data_EEG.signal_EEG);
            data_EEG.filtPara   = Atom_iwm.generateStruct(varlist,2);
        end
        
        function data_EEG = spafilEEG(data_EEG)
            fprintf('spafilEEG\n');
            COI = data_EEG.COI;
            if isempty(COI)
                COI = data_EEG.spaPara.COI_spafil;
            end
            if isempty(COI)
                COI(isempty(COI)) = 36;
            end
            signal_EEG_spafil = data_EEG.signal_EEG;
            switch data_EEG.flag_spa
                case 0
                    % default
                    fil = [];
                case 1
                    % small lap
                    fil =  data_EEG.spaPara.SmallLap;
                case 2
                    % large lap
                    fil =  data_EEG.spaPara.LargeLap;
                case 3
                    % car
                    %fil =  data_EEG.spaPara.CAR;
                    fil = ch_B4;
                case 4
                    %fil = [45,108,39,115];
                    fil = 45;
                case 5 
                    % lap 
                    COIref = COI;
                    COIref(COIref==36)  = 1;
                    COIref(COIref==104) = 2;
                    reflist = [];
                    for i_coi = 1 : numel(COIref)
                        reflist(:,i_coi) = data_EEG.getLap(COIref(i_coi));
                    end
                    flag_multref = 1;
                case 6 %car_all
                    fil = 1:size(signal_EEG_spafil,2);
            end
            
            if ~exist('flag_multref','var');
                ref             = nanmean(signal_EEG_spafil(:,fil,:,:),2);
                ref(isnan(ref)) = 0;
                %signal_EEG_spafil(:,COI,:,:)= data_EEG.regout(signal_EEG_spafil(:,COI,:,:),ref);
                signal_EEG_spafil(:,COI,:,:)= signal_EEG_spafil(:,COI,:,:) - repmat(ref,[1,numel(COI),1]);
            else
                for i_coi = 1 : numel(COIref)
                    ref = nanmean(signal_EEG_spafil(:,reflist(:,i_coi),:,:),2);
                    signal_EEG_spafil(:,COI(i_coi),:) = ...
                        signal_EEG_spafil(:,COI(i_coi),:)-ref;
                end
            end
            signal_EEG_spafil           = (signal_EEG_spafil(:,COI,:,:));
            data_EEG.signal_EEG_spafil  = signal_EEG_spafil;            
            namelist = data_EEG.spaPara.filterlist;
            data_EEG.spaPara.filtername = namelist{min(numel(namelist),data_EEG.flag_spa+1)};
        end
        
        function data_EEG = chkImpedance(data_EEG,th)
            fprintf('chkImpedance\n');
            if nargin < 2
                th = 50;
            end
            
            imp = find(data_EEG.impedances > th);
            if numel(size(data_EEG.impedances)) > 1
                imp = data_EEG.transformIdx(imp,data_EEG.impedances);
                data_EEG.spaPara.rjct_car = unique(imp(:,1));
            else
                data_EEG.spaPara.rjct_car = imp;
            end
            
        end
        
        function data_EEG = rejectCAR(data_EEG)
            CAR = data_EEG.spaPara.CAR;
            CAR(ismember(CAR,data_EEG.spaPara.rjct_car)) = [];
            data_EEG.spaPara.CAR = CAR;
        end
        
        function ref_win  = getRef(data_EEG)
            ovrlp   = 1-data_EEG.fftPara.ovrlp;
            ref_win = ceil(1+1/ovrlp : data_EEG.para.time_rest/(ovrlp)+1);
        end
        
    end
    
    methods (Access = public)
        %% Apendix
       
        
        function data_EEG = calcERSP(data_EEG,ref_win)
            fprintf('calcERSP\n');
            if nargin < 2
                ref_win = data_EEG.getRef;
            end
            if numel(ref_win) == 2
                ref_win = ref_win(1):ref_win(2);
            end
            tmp = data_EEG.tbl_fft;
            ref = tmp(ref_win,:,:,:,:);
            ref(data_EEG.detectOutlier(ref,1)) = NaN;
            ref = nanmedian(ref,1);
            tmp = 100*(tmp-ref) ./ ref;
            data_EEG.ERSP = tmp;
        end

         function data_EEG = calcERSP_dB(data_EEG,ref_win)
            fprintf('calcERSP\n');
            if nargin < 2
                ref_win = data_EEG.getRef;
            end
            if numel(ref_win) == 2
                ref_win = ref_win(1):ref_win(2);
            end
            tmp = data_EEG.tbl_fft;
            ref = tmp(ref_win,:,:,:,:);
            ref(data_EEG.detectOutlier(ref,1)) = NaN;
            ref = nanmedian(ref,1);
            tmp = 20*log10(tmp./ref);
            data_EEG.ERSP = tmp;
        end
        
        function data_EEG = findFOI(data_EEG,tmp,range_task,flag_minmax)
            if nargin < 3
                range_task = data_EEG.getRange_task;
            end
            if nargin < 4
                flag_minmax = 1;
            end
            
            fprintf('findFOI\n');
            [FOI,legend_band] = fcn_findFOI(tmp,range_task,flag_minmax);
            data_EEG.FOI = FOI;
            data_EEG.legend_band = legend_band;
        end
                
        function range_task = getRange_task(data_EEG)
            ovrlp       = data_EEG.fftPara.ovrlp;
            range_task  = data_EEG.para.time_rest/(1-ovrlp) + 1 : data_EEG.para.time_trl/(1-ovrlp);
            range_task  = ceil(range_task);
        end
        
        function t = genTime(out)
            Fs = out(1).Fs;
            if isempty(Fs)
                Fs = 1000;
            end
            t = 1/Fs:1/Fs:size(out(1).signal_EEG_spafil,1)/Fs;
            if isempty(t)
                t = 1/Fs:1/Fs:size(out(1).signal_EEG,1)/Fs;
            end            
        end
        
        function data_EEG = calcERSP_topo(data_EEG,ref_win,FOI)
            fprintf('calcERSP\n');
            if nargin < 2 || isempty(ref_win)
                ref_win = data_EEG.getRef;
            end
            tmp = data_EEG.tbl_fft;
            
            tmp         = sq(nanmedian(tmp(:,FOI,:,:),2));
            ref         = tmp(ref_win,:,:);
            %ref(data_EEG.detectOutlier(ref,1)) = NaN;
            ref         = nanmean(ref,1);
            tmp         = 100*(tmp-ref)./ref;            
            data_EEG.ERSP_topo = tmp;
        end
    end

    methods (Access = public)
        %% initialize
        function data_EEG = analysis_EEG(para)
            if nargin == 1
            data_EEG.para       = para;
            end
            data_EEG.spaPara    = data_EEG.setPara_spa;
            data_EEG.fftPara    = data_EEG.setPara_fft;
        end
        
        function self = inputData(self,sig,Fs)
            if nargin < 2
                Fs = 1000;
            end
            self.signal_EEG = sig;
            self.Fs = Fs;
            
        end
    end
end

