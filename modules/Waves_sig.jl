sig_hrv1_execute = signal_connect(GAccessor.object(builder_main,"waves_execute"), :clicked) do widget
    global signal
    if length(signal.data) > 1
        R = getR(signal)
        waves_result = Waves.ecgPeaks(signal.data, R)
        println("Wynik Waves:")
        println(waves_result)
    else
        println("ERROR: signal data is empty!")
    end
end
