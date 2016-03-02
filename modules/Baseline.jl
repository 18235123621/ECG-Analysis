module Baseline
using DSP

function _lowpass(signal, fs)
    low = Lowpass(11, fs=fs);
    butter = Butterworth(2);
    filter = digitalfilter(low, butter);
    filtered = filt(filter, signal);
    return filtered;
end

#------------------------------MovingAverage--------------------------
function movingAverage(signal, fs = 720, fc = 0.8)
	#signal = _lowpass(signal);
	Fcnorm = fc/fs;
	windowSize = round(sqrt(0.196196+Fcnorm^2)/Fcnorm);
	window = signal[1:windowSize];
	windowIndex = 1;
	windowSum = sum(window);
	filtered = copy(signal);
	filtered[floor(windowSize/2)] = signal[floor(windowSize/2)] - windowSum/windowSize;
	for i=windowSize+1:length(signal)
		if windowIndex > windowSize
			windowIndex = 1;
		end
		windowSum = windowSum - window[windowIndex];
		window[windowIndex] = signal[i];
		windowSum = windowSum + signal[i];
		filtered[i - ceil(windowSize/2)] = signal[i - ceil(windowSize/2)] - windowSum/windowSize;
		windowIndex = windowIndex + 1;
	end
	return filtered
end

#------------------------------Butterworth----------------------------
function butterworthFilter(signal, fs = 720, fc = 0.8)
	#signal = _lowpass(signal);
	high = Highpass(fc, fs=fs);
	butter = Butterworth(2);
	filter = digitalfilter(high, butter);
	filtered = filt(filter, signal);
	return filtered;
end

#------------------------------LMS------------------------------------
function lms(signal, fs = 720, fc = 0.8)
	#signal = _lowpass(signal);
	u = fc/fs*3.14;
	filtered = zeros(length(signal));
	f = signal[1];
	x = 1.0
	for i=1:length(signal)
		filtered[i] = signal[i] - x*f;
		f = f+2*u*filtered[i]*x;
	end
	return filtered
end

#------------------------------Savitzky-Golay------------------------
function savitzkyGolay(signal, fs = 360, fc = 0.8)
	#signal = _lowpass(signal);
	Fcnorm = fc/fs;
	windowSize = int(round(sqrt(0.196196+Fcnorm^2)/Fcnorm));
	polyDegree = 2;
	filtered = copy(signal);
	window = signal[1:windowSize];
	m = zeros(windowSize, polyDegree+1);
	for p=1:length(signal)-windowSize-1
		for i=1:polyDegree+1
			for j=1:windowSize
				if i == 1
					m[j,i] = 1;
				elseif i == 2
					m[j,i] = j+p-1;
				else
					m[j,i] = (j+p-1)^(i-1);
				end
			end
		end
		g = m'*m;
		a = pinv(g)*m'*window;
		y = 0;
		x = p+floor(windowSize/2);
		for i=1:length(a)
			y = y + a[i]*x.^(i-1);
		end
		filtered[p+floor(windowSize/2)] = signal[p+floor(windowSize/2)] - y;
		window = [window[2:length(window)]; signal[p+windowSize]];
	end
	return filtered
end

end
