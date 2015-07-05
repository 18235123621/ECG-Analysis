sig_hrv1_execute = signal_connect(GAccessor.object(builder_main,"load_r"), :clicked) do widget
    global signal
    if length(signal.data) > 1
        ECGInput.loadRpeaks(signal)
        println("Załadowano peaki R w próbkach nr:")
        println(getR(signal))
        reload_plot()
    else
        println("ERROR: signal record is empty!")
    end
end

sig_hrv1_execute = signal_connect(GAccessor.object(builder_main,"rpeaks_execute"), :clicked) do widget
    global signal
    if length(signal.data) > 1
        R = R_peaks.panTompkins(signal.data)
        println("Wyznaczono peaki R w próbkach nr: $R")
	ECGInput.setR(signal, R)
        reload_plot()
    else
        println("ERROR: signal record is empty!")
    end
end

