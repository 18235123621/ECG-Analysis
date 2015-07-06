sig_hrv1_execute = signal_connect(GAccessor.object(builder_main,"hrvdfa_execute"), :clicked) do widget
    global signal,dfaDone
    if length(signal.data) > 1
        dfa_result = HRV_DFA.dfa(ECGInput.getRRIntervals(signal))
        reload_dfa_plot(dfa_result)
        dfaDone = true
        println(dfa_result)
    else
        error_dialog("ERROR: signal data is empty!")
    end
end
