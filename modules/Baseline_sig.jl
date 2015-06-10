# Zmiana rozdzielczosci wykresu
sig_baseline_execute = signal_connect(GAccessor.object(builder_main,"baseline_execute"), :clicked) do widget

    global data

    baseline_type = getproperty(GAccessor.object(builder_main,"baseline_combobox_type"), :active, String)
    baseline_type = parse(Int,baseline_type);

    if baseline_type == 0
        data = Baseline.movingAverage(data)
        println("Wykonano modul Baseline (srednia kroczaca)")
    elseif baseline_type == 1
        data = Baseline.lms(data)
        println("Wykonano modul Baseline (lms)")
    elseif baseline_type == 2
        data = Baseline.butterworthFilter(data)
        println("Wykonano modul Baseline (butterworth)")
    elseif baseline_type == 3
        println("Wykonano modul Baseline (filtr savitzky-golay)")
    end

    reload_plot(wykres, data, 0, items_per_page)

end
