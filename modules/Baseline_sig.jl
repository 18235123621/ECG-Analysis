# Zmiana rozdzielczosci wykresu
sig_baseline_execute = signal_connect(GAccessor.object(builder_main,"baseline_execute"), :clicked) do widget

    global signal

    baseline_type = getproperty(GAccessor.object(builder_main,"baseline_combobox_type"), :active, String)
    baseline_type = parse(Int, baseline_type);

    if baseline_type == 0
        signal.data = Baseline.movingAverage(signal.data)
        println("Wykonano modul Baseline (srednia kroczaca)")
    elseif baseline_type == 1
        signal.data = Baseline.lms(signal.data)
        println("Wykonano modul Baseline (lms)")
    elseif baseline_type == 2
        signal.data = Baseline.butterworthFilter(signal.data)
        println("Wykonano modul Baseline (butterworth)")
    elseif baseline_type == 3
        println("Wykonano modul Baseline (filtr savitzky-golay)")
    end

    reload_plot()

end
