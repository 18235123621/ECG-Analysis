sig_hrv1_execute = signal_connect(GAccessor.object(builder_main,"waves_execute"), :clicked) do widget
    global signal
    if length(signal.data) > 1
        R = ECGInput.getR(signal)
        fs = ECGInput.getfreq(signal)
        s = int(getproperty(GAccessor.object(builder_main, "b_wielkosc_elementu_strukturalnego"), :text, String))
        dstep = int(getproperty(GAccessor.object(builder_main, "b_krok_w_pochodnej"), :text, String))
        POnSet, POffSet, QRSOnSet, QRSOffSet, TOffSet = Waves.ecgPeaks(signal.data, R, fs, s, dstep)
        ECGInput.setPonset(signal, POnSet)
        ECGInput.setPend(signal, POffSet)
        ECGInput.setQRSonset(signal, QRSOnSet)
        ECGInput.setQRSend(signal, QRSOffSet)
        ECGInput.setTend(signal, TOffSet)
        reload_plot()
    else
        error_dialog("ERROR: signal data is empty!")
    end
end
