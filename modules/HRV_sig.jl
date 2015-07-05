sig_hrv1_execute = signal_connect(GAccessor.object(builder_main,"hrv1_execute"), :clicked) do widget
    global signal
    if length(signal.data) > 1
	RRint = ECGInput.getRRIntervals(signal)
        if length(RRint) > 1
            poincare = HRV.PoincareAnalysis(RRint)
            frequency = HRV.FrequencyAnalysis(RRint)
            reload_poincare_plot(poincare)
            reload_dft_plot(frequency.WidmoX, frequency.WidmoY)
        else
            println("ERROR: RR intervals are empty!")
        end
    else
        println("ERROR: signal data is empty!")
    end
end
