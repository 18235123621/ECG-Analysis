module ECGInput
#Version: 0.1
#Requires: rdsamp, wfdbdesc from WFDB Apps
#Loads a signal record of given name and optionally given signal number and duration
#More info: http://www.physionet.org/physiotools/wag/intro.htm

export Signal, loadsignal

type Signal
    data::Array{Int, 2}
    meta::Dict{String, String}
    anno::Dict{Int, String}
end

function loadsignal(record::String, signal::Int=0, time::Any="e")
    data = readcsv(IOBuffer(readall(`LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH wfdb/rdsamp -r $record -c -s $signal -t $time`)), Int)
    meta = readdlm(IOBuffer(readall(`LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH wfdb/wfdbdesc $record`)), ':', String)
    metadict = Dict(meta[:,1], meta[:,2])
    Signal(data, metadict, Dict())
end

end
