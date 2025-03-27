function drawTF_wavelet(vi,tbl_ERSP,frq_list,fs)
%tmp = drawTF(vi,tbl_ERSP,coi,ovrlp,num_run,flag_mm)
%drawTF(tbl_ERSP[time,frq,ch,trl],coi,ovrlp,num_run,flag_mm)
freq = frq_list(:,1,1);
ERSP_coi = tbl_ERSP;
time = 1/fs : 1/fs: size(ERSP_coi,1)/fs;
vi.figure;
helperCWTTimeFreqPlot(ERSP_coi',time,freq,'surf');
hold on;
vi.setFig(-2,10)
caxis([-100 100])
end