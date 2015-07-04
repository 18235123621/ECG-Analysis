
println("\n\n#############################################");
println("#");
println("# Przetwarzanie sygnałów 2015 wersja 0.1");
println("#");
println("#############################################\n");

# ŁADOWANIE BIBLIOTEK

# Pkg.add("Gtk")
# Pkg.add("PyCall")
# Pkg.add("PyPlot")
# Pkg.add("DSP")
# Pkg.add("Dierckx")
# Pkg.add("ApproxFun")

using Gtk
using Gtk.ShortNames
using PyPlot # http://matplotlib.org/api/pyplot_summary.html

pygui(false)

# ŁADOWANIE MODUŁÓW DO PRZETWARZANIA SYGNAŁU

reload("modules/ECGInput.jl")
reload("modules/Baseline.jl")
reload("modules/Waves.jl")
reload("modules/HRV.jl")
reload("modules/hrv_dfa.jl")
using ECGInput
using Baseline
using Waves
using HRV
using hrv_dfa
# INICJALIZACJA PODSTAWOWYCH ZMIENNYCH GLOBALNYCH

current_page = 0
items_per_page = 2000
signal = Signal()

# PODSTAWOWE FUNKCJE - CORE

function reload_plot()
    global wykres, signal, current_page, items_per_page, current_page

    data = signal.data
    datalength = length(data)

    if datalength == 0
        data = [0.0]
        datalength = 1
    end

    if current_page < 0
        current_page = 0
    end

    if datalength>1
       freq = getfreq(signal);
    else
       freq =1;
    end
   

    figure(1, figsize=[9, 3], dpi=100, facecolor="#f2f1f0")

    xstart = current_page * (items_per_page )
    xend = xstart + (items_per_page )

    if xstart == 0
        xstart = 1
    end

    if xstart > datalength
        page = floor(datalength / items_per_page)
        xstart = current_page * items_per_page
        if xstart == 0
            xstart = 1
        end
        xend = datalength
    elseif xend > datalength
        xend = datalength
    end

    x = collect(xstart/freq:(1/freq):xend/freq)
  
    plt.hold(true)
    plot(x, data[xstart:xend])
    grid()
    handle_R(freq,x[1],x[length(x)])
    yMaxAxis=maximum(data[xstart:xend]) + 0.03*maximum(data[xstart:xend])
    yMinAxis=minimum(data[xstart:xend]) - 0.03*minimum(data[xstart:xend])
    axis([xstart/freq , xend/freq , yMinAxis,yMaxAxis ])
    xlabel("time [s]")
    ylabel("voltage [mV]")
    legend(["Sygnał","R peak"],ncol=4,loc=9,bbox_to_anchor=[0.5,1.25]) # 9 = legend is upper center
    savefig("wykres.jpg", format="jpg", bbox_inches="tight", pad_inches=0, facecolor="#f2f1f0")
    plt.hold(false)
    plt.close()
    ccall((:gtk_image_set_from_file,Gtk.libgtk),Void,(Ptr{Gtk.GObject},Ptr{Uint8}),wykres,bytestring("wykres.jpg"))
end

function handle_R(freq,xstart,xend)
    if length(ECGInput.getR(signal))>0 && length(signal.data)>1
        xR = filter(val-> (val>xstart && val<xend),ECGInput.getR(signal).*(1/freq));
        yR = signal.data[filter(r->(r>xstart*freq && r<xend*freq),ECGInput.getR(signal))]
        plot(xR,yR,color="red",marker="o",linewidth=0)
    else
        println("ERROR: handleR() R peaks array is empty");
    end
end

function reload_poincare_plot(poincare)

    figure(2, figsize=[3, 3], dpi=60, facecolor="#f2f1f0")
    plot(poincare.RR, poincare.RRy,color="blue",marker="o",linewidth=0)
    title("Poincare plot")
    xlabel("RR [ms]")
    ylabel("RR j+1 [ms]")
    grid()
    savefig("poincare.jpg", format="jpg", bbox_inches="tight", pad_inches=0, facecolor="#f2f1f0")
    plt.close()
    ccall((:gtk_image_set_from_file,Gtk.libgtk),Void,(Ptr{Gtk.GObject},Ptr{Uint8}),poincareView,bytestring ("poincare.jpg"))

end

function refresh_fs()
    setproperty!(GAccessor.object(builder_main,"baseline_entry_fs"), :text, getfreq(signal))
end

function hide_window(win)
    ccall((:gtk_widget_hide,Gtk.libgtk),Void,(Ptr{Gtk.GObject},),win)
end

function show_window(win)
    ccall((:gtk_widget_show_all,Gtk.libgtk),Void,(Ptr{Gtk.GObject},),win)
end

function clear_workspace()
    if hasparent(baseline_fixed)
        delete!(modules, baseline_fixed)
    end
    if hasparent(r_peaks_fixed)
        delete!(modules, r_peaks_fixed)
    end
    #= TODO: podłączyć pozostałe moduły
    if hasparent(waves_fixed)
        delete!(modules, waves_fixed)
    end
    if hasparent(hrv_dfa_fixed)
        delete!(modules, hrv_dfa_fixed)  
    end=#
    if hasparent(hrv1_fixed)
        delete!(modules, hrv1_fixed)
    end
  
end

# TWORZENIE BUILDERÓW DLA WSZYSTKICH GUI

builder_main = Gtk.GtkBuilderLeaf(filename="gui.glade");
println("Ładowanie GUI...")

# TWORZENIE UCHWYTÓW DO OKIEN ORAZ WIDGETÓW

!isdefined(:MainWindow) || destroy(MainWindow)
!isdefined(:window_change_resolution) || destroy(window_change_resolution)
!isdefined(:window_load_params) || destroy(window_load_params)

MainWindow = GAccessor.object(builder_main,"mainwindow");
modules = GAccessor.object(builder_main,"modules")
window_change_resolution = GAccessor.object(builder_main,"window_change_resolution");
window_load_params = GAccessor.object(builder_main,"window_load_params");
wykres = GAccessor.object(builder_main,"wykres")
poincareView = GAccessor.object(builder_main,"poincare")

# Okna modułów
baseline_fixed = GAccessor.object(builder_main,"baseline_fixed")
r_peaks_fixed = GAccessor.object(builder_main,"r_peaks_fixed")
waves_fixed = null #TODO: dodać w gui.glade
hrv_dfa_fixed = null #TODO: dodać w gui.glade
hrv1_fixed = GAccessor.object(builder_main,"hrv1_fixed") #TODO: dodać w gui.glade

reload_plot()
# ccall((:gtk_window_set_keep_above,Gtk.libgtk),Void,(Ptr{Gtk.GObject},Cint),MainWindow,1) # dzieki temu okno pojawia sie na gorze wszystkich okien, nie jest zminimalizowane
setproperty!(MainWindow, :window_position, Main.Base.int32(3)) # ustawienie okna na srodku
setproperty!(window_change_resolution, :window_position, Main.Base.int32(3)) # ustawienie okna na srodku
setproperty!(window_load_params, :window_position, Main.Base.int32(3)) # ustawienie okna na srodku

# OBSLUGA INTERAKCJI Z GUI

# MENU Wczytaj sygnał z pliku
sig_menu_file_open = signal_connect(GAccessor.object(builder_main,"menu_file_open"), :activate) do widget
    global signal
    sig_file = open_dialog("Wczytaj plik CSV z sygnałem EKG", MainWindow, ("*_data.csv",))
    sig_file = split(split(sig_file, '.')[1], '_')[1] # bez rozszerzenia i sufixu, jest dodawane w metodzie opensignal
    signal = opensignal(sig_file)
    println("Załadowano plik: $sig_file")
    println("Metadane:")
    println(signal.meta)
    reload_plot()
    refresh_fs()
end

# MENU Wczytaj sygnał z PhysioBank
sig_menu_record_load = signal_connect(GAccessor.object(builder_main,"menu_record_load"), :activate) do widget
    show_window(window_load_params)
end

# MENU Zapisz sygnał
sig_menu_file_save = signal_connect(GAccessor.object(builder_main,"menu_file_save"), :activate) do widget
    sig_file = save_dialog("Zapisz do pliku CSV", MainWindow, ("*_data.csv",))
    sig_file = split(split(sig_file, '.')[1], '_')[1] #bez rozszerzenia i sufixu, jest dodawane w metodzie savesignal
    savesignal(sig_file, signal)
end

# MENU Zakończ
sig_menu_file_exit = signal_connect(GAccessor.object(builder_main,"menu_file_exit"), :activate) do widget
    println("Zakończono działanie programu.")
    exit()
end

# Suwak w lewo
sig_move_left = signal_connect(GAccessor.object(builder_main,"move_left"), :clicked) do widget
    global current_page
    current_page = current_page - 1
    reload_plot()
end

# Suwak w prawo
sig_move_right = signal_connect(GAccessor.object(builder_main,"move_right"), :clicked) do widget
    global current_page
    current_page = current_page + 1
    reload_plot()
end

# Otwarcie okna zmiany rozdzielczosci wykresu
sig_menu_plot_change_resolution = signal_connect(GAccessor.object(builder_main,"menu_plot_change_resolution"), :activate) do widget
    show_window(window_change_resolution)
    setproperty!(GAccessor.object(builder_main,"entry_resolution"), "text", items_per_page)
end

# Zmiana rozdzielczosci wykresu
sig_button_save_resolution = signal_connect(GAccessor.object(builder_main,"button_save_resolution"), :clicked) do widget
    global items_per_page
    new_items_per_page = getproperty(GAccessor.object(builder_main,"entry_resolution"), :text, String)
    if new_items_per_page != ""
        items_per_page = parse(Int, new_items_per_page)
    end
    hide_window(window_change_resolution)
    println("Nowa rozdzielczosc wykresu: $items_per_page probek")
    reload_plot()
end

# Ładowanie rekordu z PhysioBank
sig_button_loadsignal = signal_connect(GAccessor.object(builder_main,"button_loadsignal"), :clicked) do widget
    global signal
    record = getproperty(GAccessor.object(builder_main,"record"), :text, String)
    seconds = getproperty(GAccessor.object(builder_main,"seconds"), :text, String)
    signalNo = 0
    signal = loadsignal(record, signalNo, seconds)
    signal.data = signal.data./ECGInput.getGain(signal)
    hide_window(window_load_params)
    println("Załadowano rekord PhysioBank: $record")
    println("Metadane:")
    println(signal.meta)
    reload_plot()
    refresh_fs()
end

# Ładowanie modułu Baseline
sig_menu_baseline = signal_connect(GAccessor.object(builder_main,"menu_baseline"), :clicked) do widget
    clear_workspace()
    push!(modules, baseline_fixed)
end

# Ładowanie modułu R_peaks
sig_menu_r_peaks = signal_connect(GAccessor.object(builder_main,"menu_r_peaks"), :clicked) do widget
    clear_workspace()
    push!(modules, r_peaks_fixed)
end

#= TODO: podłączyć pozostałe moduły
# Ładowanie modułu Waves
sig_menu_r_peaks = signal_connect(GAccessor.object(builder_main,"menu_waves"), :clicked) do widget
    clear_workspace()
    push!(modules, waves_fixed)
end
=#
# Ładowanie modułu HRV1
sig_menu_hrv1 = signal_connect(GAccessor.object(builder_main,"menu_hrv1"), :clicked) do widget
    clear_workspace()
    push!(modules, hrv1_fixed)
end
#=
# Ładowanie modułu HRV_DFA
sig_menu_r_peaks = signal_connect(GAccessor.object(builder_main,"menu_hrv_dfa"), :clicked) do widget
    clear_workspace()
    push!(modules, hrv_dfa_fixed)
end
=#

# PRZEKAZANIE SYGNAŁU DO MODUŁÓW

include("modules/Baseline_sig.jl");
include("modules/HRV_sig.jl");
include("modules/R_peaks_sig.jl");

# WYŚWIETLANIE GUI

showall(MainWindow)

push!(modules, baseline_fixed)

if !isinteractive()
    c = Condition()
    signal_connect(MainWindow, :destroy) do widget
        notify(c)
    end
    signal_connect(window_change_resolution, :destroy) do widget
        notify(c)
    end
    wait(c)
end
