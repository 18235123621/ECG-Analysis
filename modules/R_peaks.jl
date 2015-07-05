module R_peaks

using DSP
export panTompkins

function panTompkins(signal)
    #JG: Czy sygnał nie jest czasem już przefiltrowany w Baseline?
    lowPass = Lowpass(11, fs=200)
    highPass = Highpass(5, fs=200)
    butterWorth = Butterworth(2)
    filterLowPass = digitalfilter(lowPass, butterWorth)
    filterHighPass = digitalfilter(highPass, butterWorth)
    lowFiltered = filt(filterLowPass, signal)
    filtered = filt(filterHighPass, lowFiltered)

    y = zeros(length(filtered))
    for i = 3:length(filtered)-2
        y[i] = 1/8.*(-filtered[i-2]-2*filtered[i-1]+2*filtered[i+1]+filtered[i+2])
    end
    power = y.^2
  
     N=50
     for i = N:length(power)
         temp=0
         for j = 1:N
             temp = temp + power[i-(N-1)]
         end  
         power[i]=temp/N
     end
  
     threshold=0.015
     peaks = Int[]
     for i = 2:length(power)
        if power[i] >= threshold && power[i-1] < treshold #jeśli pierwsza wartość ponad próg
            push!(peaks, i) #to zapisz jej nr próbki do wektora peaków R
        end
     end
     return peaks
end

end #module
