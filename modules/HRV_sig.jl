sig_hrv1_execute = signal_connect(GAccessor.object(builder_main,"hrv1_execute"), :clicked) do widget
    global signal,hrvDone
    if length(signal.data) > 1
	RRint = ECGInput.getRRIntervals(signal)
        if length(RRint) > 1
            poincare = HRV.PoincareAnalysis(RRint)
            frequency = HRV.FrequencyAnalysis(RRint)
            reload_poincare_plot(poincare)
            reload_dft_plot(frequency.WidmoX, frequency.WidmoY)
            setproperty!(wspolczynniki, :label, "TP: $(frequency.TP)\nHF: $(frequency.HF)\nLF: $(frequency.LF)\nVLF: $(frequency.VLF)\nULF: $(frequency.ULF)\nLFLH: $(frequency.LFLH)\n")
            hrvDone = true
        else
            error_dialog("ERROR: RR intervals are empty!")
        end
    else
        error_dialog("ERROR: signal data is empty!")
    end
end
