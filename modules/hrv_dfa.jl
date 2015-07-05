module HRV_DFA

export dfa

	function dfa(signal)
		l = length(signal);
		RR = signal[1:(l - 1)];
		RRsr = mean(signal);
        
		N = 10;
		y = zeros(l);
		yTmp = 0;		
		
		iStop = length(RR);
		for i=1:iStop
			tmpRR = RR[i];
			yTmp = sum((tmpRR - RRsr).^2);
			y[i] = yTmp;
		end
		
		n = length(y);
        
		nn = n;
		ff = 0;
		trendlines = zeros(n);
		
		while n > 2
			for i=1:length(y)-n
				p = polyfit(i:i+n-1, y[i:i+n-1], 1);
				tmpTrendlines = p[1]+p[2]*(i);
				trendlines[i] = tmpTrendlines;
			end
			lt = length(trendlines);
			yyy = y[1:lt];
            
			F = sqrt(1/n*sum((yyy-trendlines).^2));
            
			n = (n/2.0);
			
			nn = [n nn];
			ff = [F ff];
		end
		
		nn = nn[1:length(nn)];
		ff = ff[1:length(ff)];
		
		for i=1:length(ff)
			if ff[i] == 0
				ff[i] = ff[i-1];
			end
		end
		
		logF = log(ff);
		logN = log(nn);
		
		a = zeros(length(logF));
		for i=1:length(logF)
			a[i] = logF[i]/logN[i];
		end
        
		return a;
	end
	
	function polyfit(x, y, polyDegree)
		m = zeros(length(x), polyDegree+1);
        
		for i=1:polyDegree+1
			for j=1:length(x)
				if i == 1
					m[j,i] = 1;
				elseif i == 2
					m[j,i] = x[j];
				else
					m[j,i] = x[j]^(i-1);
				end
			end
		end
		g = m'*m;
		a = pinv(g)*m'*y;
        
		return a;
	end
end
