module HRV

# A few simple examples; if you want to learn more about Gadfly, check out
# http://www.gadflyjl.org/

using DSP, Dierckx

export TimeDomainType, FrequencyType, Poincare, TimeDomainAnalysis, FrequencyAnalysis

immutable FrequencyType
  TP::Float64
  HF::Float64
  LF::Float64
  VLF::Float64
  ULF::Float64
  LFLH::Float64
  WidmoX::Array{Float64,1}
  WidmoY::Array{Float64,1}
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
    return round((sum(x .< differences)/length(differences))*100,1);
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
  tmp = [10000]#zeros(uint8(ceil(suma/t)));
  for i2=1:length(signal)
     if sum(signal[i1:i2]) >= t
                a=a+1;
                tmp= [tmp mean(signal[i1:i2])];
                i1=i2;
     end
  end
  tmp = tmp[2:length(tmp)];
  return std(tmp)
end

function SDNNi(signal::Array{Float64,1},t=50)
  signal=signal.*1000;
  hr=60./(signal./1000);
  a=0;
  i1=1;
  t=t*1000;
  val=1;
  suma = sum(signal);
  tmp = [10000];#zeros(uint(ceil(suma/t)));
  for i2=1:length(signal)
     if sum(signal[i1:i2]) >= t
                a=a+1;
                tmp=[tmp std(signal[i1:i2])];
                i1=i2;
     end
  end
  tmp= tmp[2:length(tmp)];
  return mean(tmp);
end



#frequency domain



function FrequencyAnalysis(signal::Array{Float64,1},aproxWindows=2.0,fs=2)

  signal = signal[1:length(signal)-1]*1000;
  newSignal =zeros(length(signal))
  newSignal[1] = signal[1];
  for r in 2:length(signal)
    newSignal[r]=newSignal[r-1] +signal[r];
  end
  newSignal=newSignal/1000;
  interval = newSignal[length(newSignal)]/length(newSignal);
  newX = [0:interval:length(newSignal)];
  signalVal = Spline1D(newSignal, signal; w=ones(length(signal)), k=3)

  newY = evaluate(signalVal,newX);

  L = length(newY);
  NFFT = nextpow2(L);
  Y = fft(newY)/NFFT;
  f = fs/2*linspace(0,1,convert(Int32,NFFT/2+1));
  absFft = 2*abs(Y[1:NFFT/2+1]);
  TP=0;
  VLF=0;
  HF=0;
  ULF=0;
  VLF=0;
  LF=0;
  signalReturnX = [1000];
  signalReturn = [1000];
  for r in 1:length(absFft)
    if(absFft[r]<=0.4)
      TP=TP+absFft[r]^2;
      signalReturnX = [ signalReturnX f[r]];
      signalReturn=[signalReturn absFft[r]];
    end
    if(absFft[r]>0.15 && absFft[r]<=0.4)
        HF=HF+absFft[r]^2;
    end
    if(absFft[r]>0.04 && absFft[r]<=0.15)
        LF=LF+absFft[r]^2;
    end
    if(absFft[r]>0.003 && absFft[r]<=0.04)
        VLF=VLF+absFft[r]^2;
    end
    if(absFft[r]<=0.003)
        ULF=ULF+absFft[r]^2;
    end
  end
  signalReturnX = signalReturnX[2:end];
  signalReturn = signalReturn[2:length(signalReturn)];
  LFLH = LF/HF;
  #tester return HF+LF+VLF+ULF - TP;
  return FrequencyType(
    round(TP,1),
    round(HF,1),
    round(LF,1),
    round(VLF,1),
    round(ULF,1),
    LFLH,
    signalReturnX,
    signalReturn);
end

  function PoincareAnalysis(signal)
    signal=signal*1000;
    RR = signal[1:length(signal)-1];
    RRy=  signal[2:length(signal)];
    SD1 = std(RR-RRy)/sqrt(2);
    SD2 = std(RR+RRy)/sqrt(2);
    return Poincare(SD1,SD2,RR,RRy);
  end
end
