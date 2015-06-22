module ECGInput
#Version: 0.3
#Requires: rdsamp, wfdbdesc from WFDB Apps
#Loads a signal record of given name and optionally given signal number and duration
#More info: http://www.physionet.org/physiotools/wag/intro.htm

export Signal, loadsignal, opensignal, savesignal, getres, getfreq, getPonset, getPend, getQRSonset, getQRSend, getR

type Signal
    data::Array{Float32, 1}
    meta::Dict{String, String}
    anno::Dict{Int, String}
end

Signal() = Signal([], Dict(), Dict())

function loadsignal(record::String, signal::Int=0, time::Any="e")
    data = readcsv(IOBuffer(readall(`wfdb/usr/bin/rdsamp -r $record -c -s $signal -t $time`)), Float32)[:,2]
    meta = readdlm(IOBuffer(readall(`wfdb/usr/bin/wfdbdesc $record`)), ':', String)
    metadict = Dict(map(lstrip, meta[7:21,1]), map(lstrip, meta[7:21,2]))
    Signal(data, metadict, Dict([(0, "START")]))
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

getres(signal::Signal) = int(split(signal.meta["ADC resolution"])[1])

function getfreq(signal::Signal)
   int(split(signal.meta["Sampling frequency"])[1])
end

getbaseline(signal::Signal) = int(split(signal.meta["Baseline"])[1])

getPonset(signal::Signal) = sort(collect(keys(filter((key, val) -> val == "Ponset", signal.anno))))

getPend(signal::Signal) = sort(collect(keys(filter((key, val) -> val == "Pend", signal.anno))))

getQRSonset(signal::Signal) = sort(collect(keys(filter((key, val) -> val == "QRSonset", signal.anno))))

getQRSend(signal::Signal) = sort(collect(keys(filter((key, val) -> val == "QRSend", signal.anno))))

getR(signal::Signal) = sort(collect(keys(filter((key, val) -> val == "R", signal.anno))))

end
