sig_hrv1_execute = signal_connect(GAccessor.object(builder_main,"hrv1_execute"), :clicked) do widget

    global signal
    if length(signal.data)>1 && length(ECGInput.getRRIntervals(signal))>1
        poincare = HRV.PoincareAnalysis(ECGInput.getRRIntervals(signal))
        frequency = HRV.FrequencyAnalysis(ECGInput.getRRIntervals(signal))
        reload_poincare_plot(poincare)
        reload_dft_plot(frequency.WidmoX,frequency.WidmoY)
    else
        println("ERROR: signal data or RR intervals is empty!")
    end
end
