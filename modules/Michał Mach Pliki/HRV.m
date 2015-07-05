clear all;
close all;
clc;

%wczytanie sygna³u, dwa dostepne przyklady, do odkomentowania jeden
% load -ascii zasoby_hrv/chf206.dat 
% signal = chf206*1000; %do milisekund


%TEST 1
%load  chf206.dat
%signal = chf206*1000;

%TEST 2
load nsr001.dat
signal = nsr001*1000;

%TEST zmniejszenie ilosci probek
%signal = signal(1:30000);
tic


%suma kolejnych odstêpów RR - genrowanie osi x tachogramu
x = zeros(1,length(signal));
suma = 0;
for i=1:length(signal)
    suma = suma + signal(i);
    x(i) = suma;
end

%tachogram


%analiza czasowa
%warto?æ ?rednia interwa³ów RR [ms]
RRsr = mean(signal);

%odchylenie standardowe RR [ms]
SDNN = sqrt((sum((RRsr-signal).^2))/(length(signal)-1));

%pierwiastek kwadratowy ze ?redniej kwadratow roznic pomiedzy kolejnymi
%dwoma interwalami RR [ms]
RMSSD = sqrt(sum((signal(2:length(signal)) - signal(1:length(signal)-1)).^2)/(length(signal)-1));

%liczba interwalow RR, ktorych roznica przekracza 50 ms
NN50 = sum(abs(signal(2:length(signal)) - signal(1:length(signal)-1)) > 50);

%odsetek roznic pomiedzy interwalami RR, ktore przekraczaja 50 ms [%]
pNN50 = NN50/(length(signal)-1)*100;

%odchylenie standardowe ze wszytkich srednich interwalow RR w 5 minutowych
%segmentach czasu [ms]
fiveMinInterval = 0;
counter = 0;
meanOfFiveMinInterval = 0;

for i=1:length(signal)
    fiveMinInterval = fiveMinInterval + signal(i);
    counter = counter + 1;
    
    if fiveMinInterval >= 5*60*1000 %5min * 60sek * 1000milisek
        
        meanOfFiveMinInterval = [meanOfFiveMinInterval fiveMinInterval/counter];
        
        counter = 0;
        fiveMinInterval = 0;
    end   
end

SDANN = std(meanOfFiveMinInterval(2:length(meanOfFiveMinInterval)));

%srednia z odchylen standardowych interwalow RR w 5 minutowych odstepach
%czasu calego zapisu
fiveMinInterval = 0;
fiveMinIntervalSamples = 0;
stdOfFiveMinInterval = 0;
for i=1:length(signal)
    fiveMinIntervalSamples = [fiveMinIntervalSamples signal(i)];
    fiveMinInterval = fiveMinInterval + signal(i);
    
    if fiveMinInterval >= 5*60*1000 %5min * 60sek * 1000milisek
        
        stdOfFiveMinInterval = [stdOfFiveMinInterval std(fiveMinIntervalSamples(2:length(fiveMinIntervalSamples)))];
        
        counter = 0;
        fiveMinInterval = 0;
        fiveMinIntervalSamples = 0;
    end   
end

SDANNindex = mean(stdOfFiveMinInterval(2:length(stdOfFiveMinInterval)));

%odchylenie standardowe roznic pomiedzy dwoma sasiadujacymi interwalami RR
%[ms]
SDSD = std(signal(2:length(signal)) - signal(1:length(signal)-1));

toc
%analiza czestotliwosciowa
%aproksymacja tachogramu funkcjami sklejanymi 3ciego stopnia - tachogram to
%nieregularne odstepy RR, w celu dokonania analizy czestotliwosciowej
%nalezy aproksymowac tachogram przedzialami i probkowac go ze stala
%czestotliwoscia probkowania, w tym przypadku 2hz
%%
tic
aproxWindow = 2; %wielkosc  okna aproksymacji
N = aproxWindow-1; 
newSignal = 0;
newX = 0;
fs = 2; %czestotliwosc probkowania
time = 0;
diff = 0;
for i=1:N:length(signal)-N
    tmpY = signal(i:i+N);
    tmpX = x(i:i+N)/1000;%w sekundach
    
    start = tmpX(1); 
    stop = tmpX(length(tmpX));
    
    xx = 0;
    for j = start+diff:1/fs:stop
        xx = [xx j];
        lastJ = j;
    end
    diff = (1/fs) - (stop - lastJ);
    xx = xx(2:length(xx));
    newX = [newX xx];
    
    
    yy = spline(tmpX, tmpY, xx);
    newSignal = [newSignal yy];
    
end
newX = newX(2:length(newX));
newSignal = newSignal(2:length(newSignal));

%tachygram po aproksymacji

L = length(newSignal);
NFFT = 2^nextpow2(L);
Y = fft(newSignal, NFFT)/NFFT;
f = fs/2*linspace(0,1,NFFT/2+1);
absFft = 2*abs(Y(1:NFFT/2+1));



%%
%ca³kowita moc widma [ms^2]
a.TP = sum(absFft(f<=0.4).^2);

%moc widmowa w zakresie wysokich czestotliwosci [ms^2]
a.HF = sum(absFft(f>0.15 & f<=0.4).^2);

%moc widma w zakresie niskich czestotliwosci [ms^2]
a.LF = sum(absFft(f>0.04 & f<=0.15).^2);

%moc widma w zakresie bardzo niskich czestotliwosci [ms^2]
a.VLF = sum(absFft(f>0.003 & f<=0.04).^2);

%moc widma w zakresie ultra niskich czestotliwosci [ms^2]
a.ULF = sum(absFft(f<=0.003).^2);

%stosunek mocy widm w zakresie niskich czestotliwosci do wysokich
%czestotliwosci
a.LFLH = a.LF/a.HF
toc

%%
%poincare
tic
RR = signal(1:length(signal)-1);
RRplusjeden = signal(2:length(signal));

%liczone na podstawie tego http://www.mathworks.com/matlabcentral/answers/24958-poincare-plot-for-hrv
SD1 = std(RR-RRplusjeden)/sqrt(2);
SD2 = std(RR+RRplusjeden)/sqrt(2);


toc
