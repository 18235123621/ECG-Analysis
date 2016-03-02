ECG Signal Analysis in Julia
============================

Analysis of an ECG signal loaded from PhysioBank (using WFDB) or a CSV file:

1. Baseline filtering by: Butterworth, moving average, Savitzky-Golay, LMS filter
2. R peaks detection
3. DFA analysis
4. Waves detection: QRS, T, P (onset & end)
5. HRV analysis
6. Poincare plot

Project is developed in Julia language with plots in PyPlot and GUI in Gtk.jl.

Requirements: Julia, GTK+, Matplotlib, PyPlot, WFDB.

University: AGH University of Science in Kraków, Poland

Subject: Signal Processing in Medical Diagnostic Systems 2 (PSwSDM2)

Authors: Michał Chrzanowski, Łukasz Dziedzic, Jerzy Głowacki, Piotr Klimiec, Dariusz Kucharski, Michał Mach, Konrad Strojny, Paweł Tokarz, Konrad Zaworski

Year: 2015

Docs: [Dokumentacja.pdf](https://github.com/niutech/ECG-Analysis/raw/development/Dokumentacja.pdf) (in Polish)