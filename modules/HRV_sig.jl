sig_baseline_execute = signal_connect(GAccessor.object(builder_main,"hrv1_execute"), :clicked) do widget

    global signal
    if length(signal.data)>1 && length(ECGInput.getRRIntervals(signal))>0
        poincare = HRV.PoincareAnalysis(signal.data)
        reload_poincare_plot(poincare)
    else
        println("ERROR: signal data or RR intervals is empty!")
    end
end
