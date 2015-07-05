sig_hrv1_execute = signal_connect(GAccessor.object(builder_main,"waves_execute"), :clicked) do widget
    global signal
    if length(signal.data) > 1
	#TODO: podpiąć moduł Waves
    else
        println("ERROR: signal data is empty!")
    end
end
