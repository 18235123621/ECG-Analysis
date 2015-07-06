module Waves
using DSP
using Wavelets

export ecgPeaks

function ecgPeaks(fecg, R, fs, s=20, dstep=3)

    # Parametry

    # Krok w pochodnej
    #dstep = 3

    #Limit wyszukiwania
    limit = 30

    QRSlimit = convert(Int64, round(0.11 * fs))
    Plimit = convert(Int64, round(0.11 * fs))
    Tlimit = convert(Int64, round(0.16 * fs))

    #Wielosc elementu strukturalnego
    #s = 20

    #Ilosc elementow ktore sa brane pod uwage
    N = length(fecg)

    i = 1
    while i <= length(R)-1 && R[i+1] < N
        i = i + 1
    end
    R = R[1:i]
    NR = i
    
    # Przesuniecie po filtracji
    move = 15
    
    responsetype = Lowpass(11; fs=360)
    designmethod = Butterworth(4)
    fecg = filt(digitalfilter(responsetype, designmethod), fecg)
    fecg[1:(N-move)+1] = fecg[move:N]
    fecg = denoise(fecg)

    # Operacje morfologiczne na sygnale
    M = copy(fecg)

    ROnSet = Int64[]
    ROffSet = Int64[]
    Q = Int64[]
    S = Int64[]
    POnSet = Int64[]
    POffSet = Int64[]
    TOnSet = Int64[]
    TOffSet = Int64[]
    
    for n = 1:N
        if n <= s + 1
            M[n] = (maximum(fecg[1:n+s]) + minimum(fecg[1:n+s]) - 2 * fecg[n])/s
        elseif n >= N-s-1
            M[n] = (maximum(fecg[n-s:N]) + minimum(fecg[n-s:N]) - 2 *  fecg[n])/s
        else
            M[n] = (maximum(fecg[n-s:n+s]) + minimum(fecg[n-s:n+s]) - 2 * fecg[n])/s
        end
    end
    
  
   for n = 1:NR
      dt = (M[R[n]+dstep] - M[R[n]]) / dstep
      
      
      # Szukanie ROffSet

      localmax = R[n]+1
      for i = 2:1:limit
        if R[n] + dstep + i < N
            dtn = (M[R[n] + dstep + i] - M[R[n]+i]) / dstep
            if (dtn * dt) < 0 && dtn < 0
                if M[localmax] < M[R[n] + i]
		  localmax = R[n]+i
                end
            end
            dt = copy(dtn)
        end
     
     end   
      push!(ROffSet, localmax)
      
      dt = (M[R[n]] - M[R[n] - dstep]) / dstep

      # Szukanie ROnSet
      
      localmax = R[n]-1
      for i = 2:1:limit
        dtn = (M[R[n]-i] - M[R[n]-i-dstep]) / dstep
        if (dtn * dt) < 0 && dtn > 0
            
            if M[localmax] < M[R[n]-i]
		  localmax = R[n]-i
                end
        end
        dt = copy(dtn)
      end
      ROnSet = push!(ROnSet, localmax)
    
    end
    
    # Szukanie Q
    
    ROnSetN = length(ROnSet)
    #println(ROnSetN)
    for n = 1:ROnSetN
    
      dt = (M[ROnSet[n]] - M[ROnSet[n]-dstep]) / dstep
      localmin = ROnSet[n]-1
      for i = 2:1:limit
          if ROnSet[n] + dstep + i < N
            dtn = (M[ROnSet[n]-i] - M[ROnSet[n]-i-dstep]) / dstep
            if (dtn * dt) < 0 && dtn < 0
		if M[localmin] > M[ROnSet[n]-i]
		  localmin = ROnSet[n]-i
                end              
            end
            dt = copy(dtn)
          end
      end
      push!(Q, localmin)
    end

    # Szukanie S
    ROffSetN = length(ROffSet)
    #println(ROffSetN)
    
    for n = 1:ROffSetN
      dt = (M[ROffSet[n]+dstep] - M[ROffSet[n]]) / dstep
      localmin = ROffSet[n]+1
      for i = 2:1:limit
      if(ROffSet[n]+i+dstep)<N
          if ROffSet[n] + dstep + i < N
            dtn = (M[ROffSet[n]+dstep+i] - M[ROffSet[n]+i]) / dstep
            if (dtn * dt) < 0 && dtn > 0
	      if M[localmin] > M[ROffSet[n]+i]
		  localmin = ROffSet[n]+i
                end 
            end
            dt = copy(dtn)
          end
          end
      end
      push!(S, localmin)
    end
  
   # Szukanie P
    PN = length(Q)

    
    for n = 1:PN
      

      # Szukanie POffSet
      if Q[n] - dstep - limit > 0
      dt = (M[Q[n]+dstep] - M[Q[n]]) / dstep
      localmax = Q[n]-1
      for i = 2:1:limit
          
            dtn = (M[Q[n]-i] - M[Q[n]-i-dstep]) / dstep
            if (dtn * dt) < 0 && dtn > 0
              
              if M[localmax] < M[Q[n]-i]
		  localmax = Q[n]-i
	      end
            end
            dt = copy(dtn)
         
      end
      push!(POffSet, localmax)
      end
     
      shift=i    
       if Q[n] - dstep - limit - shift > 0
      dt = (M[Q[n]-shift] - M[Q[n]-dstep-shift]) / dstep

      # Szukanie POnSet
      localmax = Q[n]-shift-1
      
      for i = 2:1:limit
      #if Q[n] + dstep + i < N
        dtn = (M[Q[n]-i-shift] - M[Q[n]-i-dstep-shift]) / dstep
        if (dtn * dt) < 0 && dtn > 0
	    if M[localmax] < M[Q[n]-i-shift]
		  localmax = Q[n]-i-shift
            end
          
          
        end
        dt = copy(dtn)
       
      end
      push!(POnSet, localmax)
    end
end
    # Szukanie T
    TN = length(S)

    for n = 1:TN
      dt = (M[S[n]+dstep] - M[S[n]]) / dstep

      # Szukanie TOnSet
      localmax = S[n]+1
      for i = 2:1:(2*limit)
      if(S[n]+i+dstep)<N
        dtn = (M[S[n]+i+dstep] - M[S[n]+i]) / dstep
        if (dtn * dt) < 0 && dtn < 0
         dtn = (M[S[n]+i+dstep] - M[S[n]+i]) / dstep
           if M[localmax] < M[S[n]+i]
		  localmax = S[n]+i
          end 
        end
        end
        dt = copy(dtn)
      end
      push!(TOnSet, localmax)
      
      
     

      
      # Szukanie TOffSet
      
      shift=i
      if(S[n]+limit+dstep+shift)<N
            
      dt = (M[S[n]+dstep+shift] - M[S[n]+shift]) / dstep
      
      localmax = S[n]+1+shift
      for i = 2:1:(2*limit)
	if(S[n]+i+dstep+shift)<N
	  dtn = (M[S[n]+i+dstep+shift] - M[TOnSet[n]+i+shift]) / dstep
	  if (dtn * dt) < 0 && dtn < 0
	    
	    if M[localmax] < M[S[n]+i+shift]
		  localmax = S[n]+i+shift
          end 
	  
	  end
	  dt = copy(dtn)
	  end
	
    end
      push!(TOffSet, localmax)
    end
  
  end

    QRSOnSet = R
    QRSOffSet = S
    
    return POnSet, POffSet, QRSOnSet, QRSOffSet, TOffSet

end #function

end #module
