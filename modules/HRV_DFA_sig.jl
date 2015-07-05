sig_hrv1_execute = signal_connect(GAccessor.object(builder_main,"hrvdfa_execute"), :clicked) do widget
    global signal
    if length(signal.data) > 1
        dfa_result = HRV_DFA.dfa(ECGInput.getRRIntervals(signal))
        println("Wynik HRV_DFA:")
        println(dfa_result)
    else
        println("ERROR: signal data is empty!")
    end
end
