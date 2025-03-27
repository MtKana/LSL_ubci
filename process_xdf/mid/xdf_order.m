function xdf = xdf_order(data_xdf)
    n = size(data_xdf,2);
    for ch = 1 : n
        if data_xdf{1,ch}.info.name == "LSL-DAQ-1"
            xdf(1) = ch;
        elseif data_xdf{1,ch}.info.name == "EGI NetAmp 0"
            xdf(2) = ch;
        elseif data_xdf{1,ch}.info.name == "Keyboard"
            xdf(3) = ch;
        elseif data_xdf{1,ch}.info.name == "Tobii Pro Spectrum"
            xdf(4) = ch;
        elseif data_xdf{1,ch}.info.name == "AudioCaptureWin"
            xdf(5) = ch;
        end
    end
end