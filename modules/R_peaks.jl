module R_peaks
using DSP

function panTompkins(signal, fs)
    lowPass = Lowpass(11, fs=fs);
    highPass = Highpass(5, fs=fs);
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

    inted = zeros(length(power));

     NN=fs/4;
     for i = NN:length(power)
         temp=0;
         for j = 1:NN
             temp = temp + power[i-(NN-j)];
         end
         inted[i]=temp/NN;
     end


     threshold=mean(inted[1:fs]);
     r_peaks = 0;
     values = 0;
     doing = 0;
     m = 0;
     for i = 1:length(inted)
        if i%fs == 0 && i+fs < length(inted)
          threshold = mean(inted[i:i+fs]);
        end
        if inted[i] >= threshold
	     r_peaks = [r_peaks i];
	     values = [values inted[i]];
             doing = 1;
	     continue;
         end

	if doing == 1
	    doing = 0;
	    ind = indmax(values);
            m = [m r_peaks[ind]];
	    values = 0;
	    r_peaks = 0;
	end
     end

    Rs = 0;

    for i = 2:length(m)
       rTmp = m[i]-43;
       newR = indmax(signal[rTmp-int(fs/10):rTmp+int(fs/10)]);
       Rs = [Rs newR+rTmp-int(fs/10)];
    end
    return Rs[2:length(Rs)];
end

end
