sig_hrv1_execute = signal_connect(GAccessor.object(builder_main,"load_r"), :clicked) do widget

    global signal
    if length(signal.data)>1 
        ECGInput.loadRpeaksFromAnnotations(signal)
        reload_plot()
    else
        println("ERROR: signal record is empty!")
    end
end
