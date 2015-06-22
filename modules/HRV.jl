module HRV

using DSP, ApproxFun, Dierckx

immutable FrequencyType
  TP::Int32
  HF::Int32
  LF::Int32
  VLF::Int32
  ULF::Int32
  LFLH::Float64
  Widmo::Array{Float64,1}
end

immutable Poincare
  SD1::Float64
  SD2::Float64
  RR::Array{Float64,1}
  RRy::Array{Float64,1}
end

immutable TimeDomainType
  pNN::Float64
  pNNCounter::Float64
  RMSSD::Float64
  Max::Int32
  Min::Int32
  Mean::Float64
  Median::Int32
  SDNN::Float64
  SDANNi::Float64
  SDANN::Float64
  SDSD::Float64
end

function TimeDomainAnalysis(signal::Array{Float64,1},x=50,t=50)
  return TimeDomainType(
    pNN_val(signal,x),
    pNNCounter_val(signal,x),
    RMSSD_val(signal),
    max_val(signal),
    min_val(signal),
    mean_val(signal),
    median_val(signal),
    SDNN_val(signal),
    SDANNi_val(signal,t),
    SDANN_val(signal,t),
    SDSD_val(signal)
    );
end

function pNN_val(signal::Array{Float64,1},x=50)
     signal=signal.*1000;
    differences=abs(diff(signal));
    return sum(x .< differences);
end
  
function pNNCounter_val(signal::Array{Float64,1},x=50)
     signal=signal.*1000;
    differences=abs(diff(signal));
    return (sum(x .< differences)/length(differences))*100;
end

function pNNx_val(signal::Array{Float64,1},x=50)
     signal=signal.*1000;
    differences=abs(diff(signal));
    return pNNx(sum(x .< differences) ,
    (sum(x .< differences)/length(differences))*100);
end

function RMSSD_val(signal::Array{Float64,1})
   signal=signal.*1000;
   differences=abs(diff(signal));
   output=sqrt(sum(differences.^2)/length(differences));
  return round(output*10)/10;
end

function max_val(signal::Array{Float64,1})
   signal=signal.*1000; #%convert ibi to ms

   hr=60./(signal./1000);
  val = round(maximum(signal)*10)/10;;
   return val;
end

function min_val(signal::Array{Float64,1})
   signal=signal.*1000; #%convert ibi to ms

   hr=60./(signal./1000);
  val = round(minimum(signal)*10)/10;;
   return val;
end

function mean_val(signal::Array{Float64,1})
   signal=signal.*1000; #%convert ibi to ms

   hr=60./(signal./1000);
  val = round(mean(signal)*10)/10;;
   return val;
end

function median_val(signal::Array{Float64,1})
   signal=signal.*1000; #%convert ibi to ms

   hr=60./(signal./1000);
  val = round(median(signal)*10)/10;;
   return val;
end

function SDNN_val(signal::Array{Float64,1})
   signal=signal.*1000; #%convert ibi to ms

   hr=60./(signal./1000);
  val = round(std(signal)*10)/10;;
   return val;
end

function SDANN_val(signal::Array{Float64,1},t=50);
  result = SDANN(signal,t)
   val = round(result*10)/10;
  return val;
end

function SDANNi_val(signal::Array{Float64,1},t=50);
   result = SDNNi(signal,t)
   val = round(result*10)/10;
  return val;
end

function SDSD_val(signal::Array{Float64,1})
   signal=signal.*1000; #%convert ibi to ms

   hr=60./(signal./1000);
  val = std( signal[1:length(signal)-1]-signal[2:length(signal)]);
  val = round(val*10)/10;
   return val;
end

function SDANN(signal::Array{Float64,1},t)
  signal=signal.*1000;
  hr=60./(signal./1000);
  a=0;
  i1=1;
  t=t*1000;
  val=1;
  suma = sum(signal);
  tmp = zeros(uint8(ceil(suma/t)));
  for i2=1:length(signal)
     if sum(signal[i1:i2]) >= t
                a=a+1;
                tmp[a]=mean(signal[i1:i2]);
                i1=i2;
     end
  end
  return std(tmp)
end

function SDNNi(signal::Array{Float64,1},t)
  signal=signal.*1000;
  hr=60./(signal./1000);
  a=0;
  i1=1;
  t=t*1000;
  val=1;
  suma = sum(signal);
  tmp = zeros(uint8(ceil(suma/t)));
  for i2=1:length(signal)
     if sum(signal[i1:i2]) >= t
                a=a+1;
                tmp[a]=std(signal[i1:i2]);
                i1=i2;
     end
  end
    return mean(tmp);
end


#frequency domain


function FrequencyAnalysis(signal::Array{Float64,1},aproxWindows=2,fs=2)

  #s = Chebyshev([(-1)*aproxWindows,aproxWindows])
  #f = Fun(signal,s);
  #newsignal= ApproxFun.sample(f,20);
  #low = Lowpass(0.45);
	#butter = Butterworth(2);
	#filter = digitalfilter(low, butter);
	#signal = filt(filter, signal);
  
  newSignal =zeros(length(signal)) 
  newSignal[1] = signal[1];
  for r in 2:length(signal)
    newSignal[r]=newSignal[r-1] +signal[r];
  end
  interval = newSignal[length(newSignal)]/length(newSignal);
  newX = [0:interval:length(newSignal)];
  signalVal = Spline1D(newSignal, signal; w=ones(length(signal)), k=3, bc="nearest", s=0.0)  
  newY = evaluate(signalVal,newX);
  L = length(newY);
  NFFT = nextpow2(L );
  Y = fft(newY)/NFFT;
  f = fs/2*linspace(0,1,convert(Int32,NFFT/2+1));
  absFft = 2*abs(Y[1:NFFT/2+1]);
  TP=0;
  VLF=0;
  HF=0;
  ULF=0;
  VLF=0;
  LF=0;
  for r in 1:length(absFft)
    if(absFft[r]<=0.4)
        TP=TP+1;
    end
    if(absFft[r]>0.15 && absFft[r]<=0.4)
        HF=HF+1;
    end
    if(absFft[r]>0.04 && absFft[r]<=0.15)
        LF=LF+1;
    end
    if(absFft[r]>0.003 && absFft[r]<=0.04)
        VLF=VLF+1;
    end
    if(absFft[r]<=0.003)
        ULF=ULF+1;
    end
  end
    TP = TP^2
    HF=HF^2;
    LF=LF^2;
    VLF=VLF^2;
    ULF =ULF^2;
    LFLH = LF/HF;

  return FrequencyType(TP,HF,LF,VLF,ULF,LFLH,absFft);
end

function PoincareAnalysis(signal::Array{Float64,1})
  RR = signal[1:length(signal)-1];
  RRy = signal[2:length(signal)];
  SD1 = std(RR-RRy)/sqrt(2);
  SD2 = std(RR+RRy)/sqrt(2);
  return Poincare(SD1,SD2,RR,RRy);
end

end #module
