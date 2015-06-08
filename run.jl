using Gtk
using Gtk.ShortNames
using PyPlot # http://matplotlib.org/api/pyplot_summary.html

include("modules/ECGInput.jl")
include("modules/Baseline.jl")
using ECGInput
using Baseline

pygui(false)
!isdefined(:MainWindow) || destroy(MainWindow)

println("\n\n#############################################");
println("#");
println("# Przetwarzanie sygnałów 2015");
println("#");
println("#############################################\n");

###################################
#
# PODSTAWOWE FUNKCJE - CORE
#
###################################

function reload_plot(wykres, arg_data, page=0, items_per_page=5000)

    if page < 0
        page = 0
    end

    figure(1, figsize=[9, 2], dpi=100, facecolor="#f2f1f0")

    xstart = page * items_per_page
    xend = xstart + items_per_page
    if xstart == 0
        xstart = 1
    end

    if length(arg_data) == 0
        xstart = 1
        xend = 0
    elseif xstart > length(arg_data)
        page = floor(length(arg_data) / items_per_page)
        xstart = page * items_per_page
        if xstart == 0
            xstart = 1
        end
        xend = length(arg_data)
    elseif xend > length(arg_data)
        xend = length(arg_data)
    end

    global current_page
    current_page = page

    x = [xstart:xend]

    println("Generuje wykres z przedzialu $xstart:$xend");

    plot(x,arg_data[xstart:xend])
    savefig("wykres.jpg",format="jpg",bbox_inches="tight",pad_inches=0,facecolor="#f2f1f0")
    plt.close()
    ccall((:gtk_image_set_from_file,Gtk.libgtk),Void,(Ptr{Gtk.GObject},Ptr{Uint8}),wykres,bytestring("wykres.jpg"))
end

###################################
#
# INICJALIZACJA ZMIENNYCH ORAZ WCZYTYWANIE GUI Z PLIKU
#
###################################

current_page = 0
items_per_page = 2000

builder = Gtk.GtkBuilderLeaf(filename="gui.glade");
MainWindow = GAccessor.object(builder,"mainwindow");
window_change_resolution = GAccessor.object(builder,"window_change_resolution");
wykres = GAccessor.object(builder,"wykres")
data = []
reload_plot(wykres, data, 0, items_per_page)

# ccall((:gtk_window_set_keep_above,Gtk.libgtk),Void,(Ptr{Gtk.GObject},Cint),MainWindow,1) # dzieki temu okno pojawia sie na gorze wszystkich okien, nie jest zminimalizowane
setproperty!(MainWindow, :window_position, Main.Base.int32(3)) # ustawienie okna na srodku
setproperty!(window_change_resolution, :window_position, Main.Base.int32(3)) # ustawienie okna na srodku

###################################
#
# OBSLUGA INTERAKCJI Z GUI
#
###################################

# MENU Wczytaj sygnał
sig_menu_file_open = signal_connect(GAccessor.object(builder,"menu_file_open"), :activate) do widget
    global data
    sig_file = open_dialog("Wczytaj plik z sygnałem EKG"; parent = MainWindow)
    data = readdlm(sig_file)
    reload_plot(wykres, data, 0, items_per_page)
end

# MENU Zakończ
sig_menu_file_exit = signal_connect(GAccessor.object(builder,"menu_file_exit"), :activate) do widget
    println("Zakończono działanie programu.")
    exit()
end

# Suwak w lewo
sig_move_left = signal_connect(GAccessor.object(builder,"move_left"), :clicked) do widget
    reload_plot(wykres, data, current_page-1, items_per_page)
end

# Suwak w prawo
sig_move_right = signal_connect(GAccessor.object(builder,"move_right"), :clicked) do widget
    reload_plot(wykres, data, current_page+1, items_per_page)
end

# Zmiana rozdzielczosci wykresu
sig_menu_plot_change_resolution = signal_connect(GAccessor.object(builder,"menu_plot_change_resolution"), :activate) do widget
    ccall((:gtk_widget_show,Gtk.libgtk),Void,(Ptr{Gtk.GObject},),window_change_resolution)
    setproperty!(GAccessor.object(builder,"entry_resolution"), "text", items_per_page)
end

sig_button_save_resolution = signal_connect(GAccessor.object(builder,"button_save_resolution"), :clicked) do widget
    global data
    global items_per_page
    new_items_per_page = getproperty(GAccessor.object(builder,"entry_resolution"), :text, String)
    if new_items_per_page != ""
        items_per_page = parse(Int,new_items_per_page)
    end
    ccall((:gtk_widget_hide,Gtk.libgtk),Void,(Ptr{Gtk.GObject},),window_change_resolution)
    println("Nowa rozdzielczosc wykresu: $items_per_page probek")
    reload_plot(wykres, data, 0, items_per_page)
end

#signal_handler_disconnect(open_, id2)


###################################
#
# WYSWIETLANIE GUI
#
###################################

showall(MainWindow)
showall(window_change_resolution)
ccall((:gtk_widget_hide,Gtk.libgtk),Void,(Ptr{Gtk.GObject},),window_change_resolution)

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

