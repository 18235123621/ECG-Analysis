module R_peaks
using DSP

	function panTompkins(signal)
    lowPass = Lowpass(11, fs=200);
    highPass = Highpass(5, fs=200);
    butterWorth = Butterworth(2);
    filterLowPass = digitalfilter(lowPass, butterWorth);
    filterHighPass = digitalfilter(highPass, butterWorth);
    lowFiltered = filt(filterLowPass, signal);
    filtered = filt(filterHighPass, lowFiltered);

    y = zeros(length(filtered));
    for i = 3:length(filtered)-2
        y[i]=1/8.*(-filtered[i-2]-2*filtered[i-1]+2*filtered[i+1]+filtered[i+2]);    
    end
    power = y.^2;
  
     N=50;
     for i = N:length(power)
         temp=0;
         for j = 1:N
             temp = temp + power[i-(N-1)];
         end  
         power[i]=temp/N;
     end
  
     threshold=0.015;
     for i = 1:length(power)
        if power[i] >= threshold
             power[i] = power[i];
         else
             power[i] = 0;
         end
     end
  
   println(power);
    return power;           
end

end
