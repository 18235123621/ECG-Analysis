module Baseline
using DSP

#------------------------------MovingAverage--------------------------
	function movingAverage(signal, fs = 720, fc = 0.8)

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

		high = Highpass(fc, fs=fs);
		butter = Butterworth(2);
		filter = digitalfilter(high, butter);

		filtered = filt(filter, signal);

		return filtered;

	end

#------------------------------LMS------------------------------------
	function lms(signal, fs = 720, fc = 0.8)

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


end
