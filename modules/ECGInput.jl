module ECGInput
#Version: 0.2
#Requires: rdsamp, wfdbdesc from WFDB Apps
#Loads a signal record of given name and optionally given signal number and duration
#More info: http://www.physionet.org/physiotools/wag/intro.htm

export Signal, loadsignal, opensignal, savesignal

type Signal
    data::Array{Float32, 1}
    meta::Dict{String, String}
    anno::Dict{Int, String}
end

function loadsignal(record::String, signal::Int=0, time::Any="e")
    data = readcsv(IOBuffer(readall(`../wfdb/usr/bin/rdsamp -r $record -c -s $signal -t $time`)), Float32)[:,2]
    meta = readdlm(IOBuffer(readall(`../wfdb/usr/bin/wfdbdesc $record`)), ':', String)
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

end
