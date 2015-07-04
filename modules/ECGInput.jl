module ECGInput
#Version: 0.3
#Requires: rdsamp, wfdbdesc from WFDB Apps
#Loads a signal record of given name and optionally given signal number and duration
#More info: http://www.physionet.org/physiotools/wag/intro.htm

export Signal, loadsignal, opensignal, savesignal, getres, getfreq, getPonset, getPend, getQRSonset, getQRSend, getR , getRRIntervals

type Signal
    record::String
    data::Array{Float32, 1}
    meta::Dict{String, String}
    anno::Dict{Int, String}
    time::Any
end

Signal() = Signal("",[], Dict(), Dict(),"e")

function loadsignal(record::String, signal::Int=0, time::Any="e")
    data = readcsv(IOBuffer(readall(`wfdb/usr/bin/rdsamp -r $record -c -s $signal -t $time`)), Float32)[:,2]
    meta = readdlm(IOBuffer(readall(`wfdb/usr/bin/wfdbdesc $record`)), ':', String)
    startingTimeIndex = 8
    for i=1:length(meta)
       if isdefined(meta,i)
          if meta[i,1]=="Starting time"
             startingTimeIndex=i
             break
          end
       end
    end
    metadict = Dict(map(lstrip, meta[startingTimeIndex:startingTimeIndex+14,1]), map(lstrip, meta[startingTimeIndex:startingTimeIndex+14,2]))
    Signal(record,data, metadict, Dict([(0, "START")]),time)
end

function loadRpeaksFromAnnotations(signal)
    record = signal.record
    time  = signal.time
    downloadedAnnoLines = readlines(IOBuffer(readall(`wfdb/usr/bin/rdann -r $record -a atr -t $time -p N`)))
    for i=downloadedAnnoLines
        signal.anno[int(split(i)[2])] = "R"
    end
end

function opensignal(filename::String)
    data = readcsv("$(filename)_data.csv", Float32)[:,1]
    meta = readcsv("$(filename)_meta.csv", String)
    anno = readcsv("$(filename)_anno.csv", String)
    metadict = Dict(meta[:,1], meta[:,2])
    annodict = Dict(map(parseint, anno[:,1]), anno[:,2])
    Signal(data, metadict, annodict)
end

function savesignal(filename::String, signal::Signal)
    writecsv("$(filename)_data.csv", signal.data)
    writecsv("$(filename)_meta.csv", signal.meta)
    writecsv("$(filename)_anno.csv", signal.anno)
end

function getGain(signal) 
    return int(split(signal.meta["Gain"])[1])
end

getres(signal) = int(split(signal.meta["ADC resolution"])[1])

getfreq(signal) = int(split(signal.meta["Sampling frequency"])[1])

#getbaseline(signal::Signal) = int(split(signal.meta["Baseline"])[1])

getPonset(signal) = sort(collect(keys(filter((key, val) -> val == "Ponset", signal.anno))))

getPend(signal) = sort(collect(keys(filter((key, val) -> val == "Pend", signal.anno))))

getQRSonset(signal) = #=[340 640] DANE TESTOWE NIE KASOWAĆ!=#
sort(collect(keys(filter((key, val) -> val == "QRSonset", signal.anno))))

getQRSend(signal) = #=[390 900] DANE TESTOWE NIE KASOWAĆ!=#
sort(collect(keys(filter((key, val) -> val == "QRSend", signal.anno))))

getR(signal) = sort(collect(keys(filter((key, val) -> val == "R", signal.anno))))

function getRRIntervals(signal) 
    intervals = [0]
    lastRtime = 0
    for r = getR(signal)
        thisRtime = r*(1/getfreq(signal))
        intervals=[intervals thisRtime-lastRtime ]
        lastRtime=thisRtime
    end
    return intervals[2:end]
end

end
