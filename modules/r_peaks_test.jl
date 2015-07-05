include("r_peaks.jl")
using Gadfly
using R_peaks


#C:\Users\ludzdz\sygnaĹ‚y\ekg_zasoby
signal = readdlm("ekg_zasoby/228_V1.dat")
signal = signal[1:10000]
r_peaks = R_peaks.panTompkins(signal, 360);
plot(layer(x=1:length(signal), y = signal, Geom.line),
     layer(x=r_peaks, y = signal[r_peaks], Geom.line,  Theme(default_color=color("orange"))));
#plot(x=1:length(power), y = power, Geom.line)


