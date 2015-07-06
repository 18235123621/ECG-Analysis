# Zmiana rozdzielczosci wykresu
sig_baseline_execute = signal_connect(GAccessor.object(builder_main,"baseline_execute"), :clicked) do widget
    global signal
    if length(signal.data) > 1
        baseline_type = int(getproperty(GAccessor.object(builder_main,"baseline_combobox_type"), :active, Int))
        baseline_fs = int(getproperty(GAccessor.object(builder_main,"baseline_entry_fs"), :text, String))
        baseline_fc = float(getproperty(GAccessor.object(builder_main,"baseline_entry_fc"), :text, String))
        if baseline_type == 0
            signal.data = Baseline.movingAverage(signal.data, baseline_fs, baseline_fc)
            println("Wykonano modul Baseline (srednia kroczaca)")
        elseif baseline_type == 1
            signal.data = Baseline.lms(signal.data, baseline_fs, baseline_fc)
            println("Wykonano modul Baseline (lms)")
        elseif baseline_type == 2
            signal.data = Baseline.butterworthFilter(signal.data, baseline_fs, baseline_fc)
            println("Wykonano modul Baseline (butterworth)")
        elseif baseline_type == 3
            println("Wykonano modul Baseline (filtr savitzky-golay)")
        end
        reload_plot()
    else
        error_dialog("ERROR: signal data is empty!")
    end
end
