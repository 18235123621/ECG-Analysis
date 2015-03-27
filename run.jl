using Gtk.ShortNames

println("\n\n#############################################");
println("#");
println("# Przetwarzanie sygnałów 2015");
println("#");
println("#############################################\n");

# GtkWindowLeaf(name="", parent, width-request=-1, height-request=-1, visible=TRUE, sensitive=TRUE, app-paintable=FALSE, can-focus=FALSE, has-focus=FALSE, is-focus=FALSE, can-default=FALSE, has-default=FALSE, receives-default=FALSE, composite-child=FALSE, style, events=0, no-show-all=FALSE, has-tooltip=FALSE, tooltip-markup=NULL, tooltip-text=NULL, window, double-buffered=TRUE, halign=GTK_ALIGN_FILL, valign=GTK_ALIGN_FILL, margin-left=0, margin-right=0, margin-top=0, margin-bottom=0, margin=0, hexpand=FALSE, vexpand=FALSE, hexpand-set=FALSE, vexpand-set=FALSE, expand=FALSE, border-width=0, resize-mode=GTK_RESIZE_QUEUE, child, type=GTK_WINDOW_TOPLEVEL, title="My window", role=NULL, resizable=TRUE, modal=FALSE, window-position=GTK_WIN_POS_NONE, default-width=-1, default-height=-1, destroy-with-parent=FALSE, hide-titlebar-when-maximized=FALSE, icon, icon-name=NULL, screen, type-hint=GDK_WINDOW_TYPE_HINT_NORMAL, skip-taskbar-hint=FALSE, skip-pager-hint=FALSE, urgency-hint=FALSE, accept-focus=TRUE, focus-on-map=TRUE, decorated=TRUE, deletable=TRUE, gravity=GDK_GRAVITY_NORTH_WEST, transient-for, attached-to, opacity=1.000000, has-resize-grip=TRUE, resize-grip-visible=TRUE, application, ubuntu-no-proxy=FALSE, is-active=FALSE, has-toplevel-focus=FALSE, startup-id, mnemonics-visible=TRUE, focus-visible=TRUE, )

MainWindow = @Window("Przetwarzanie sygnałów EKG", 950, 600, false, true)

ccall((:gtk_window_set_keep_above,Gtk.libgtk),Void,(Ptr{Gtk.GObject},Cint),MainWindow,1) # dzieki temu okno pojawia sie na gorze wszystkich okien, nie jest zminimalizowane

setproperty!(MainWindow, :window_position, Main.Base.int32(3)) # ustawienie okna na srodku
# ccall((:gtk_window_set_position,Gtk.libgtk),Void,(Ptr{Gtk.GObject},Cint),MainWindow,Main.Base.int32(3)) # to samo co wyzej

g = @Grid()   # gtk3-only (use @Table() for gtk2)

setproperty!(g, :column_spacing, 15)  # introduce a 15-pixel gap between columns

file = @MenuItem("_Plik")
    filemenu = @Menu(file)
    open_ = @MenuItem("Otwórz")
    push!(filemenu, open_)
    push!(filemenu, @SeparatorMenuItem())
    quit = @MenuItem("Zakończ")
    push!(filemenu, quit)
mb = @MenuBar()
push!(mb, file)


id2 = signal_connect(open_, :activate) do widget
	println("otwieram")
end
#signal_handler_disconnect(open_, id2)


g[1:90,1] = mb
push!(MainWindow, g)

showall(MainWindow)

if !isinteractive()
    c = Condition()
    signal_connect(MainWindow, :destroy) do widget
        notify(c)
    end
    wait(c)
end
