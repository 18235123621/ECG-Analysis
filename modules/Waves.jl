module Waves
using DSP
using Wavelets

export ecgPeaks

function ecgPeaks(fecg, R, s=20, dstep=3)

    # Parametry

    # Krok w pochodnej
    #dstep = 3

    #Limit wyszukiwania
    limit = 50

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
      for i = 2:1:limit
        if R[n] + dstep + i < N
            dtn = (M[R[n] + dstep + i] - M[R[n]+i]) / dstep
            if (dtn * dt) < 0 && dtn < 0
                ROffSet = push!(ROffSet, R[n]+i)
                break
            end
            dt = copy(dtn)
        end
      end

      dt = (M[R[n]] - M[R[n] - dstep]) / dstep

      # Szukanie ROnSet
      for i = 2:1:limit
        dtn = (M[R[n]-i] - M[R[n]-i-dstep]) / dstep
        if (dtn * dt) < 0 && dtn > 0
            ROnSet = push!(ROnSet, R[n]-i)
            break
        end
        dt = copy(dtn)
      end
    end

    # Szukanie Q
    ROnSetN = length(ROnSet)
    #println(ROnSetN)
    for n = 1:ROnSetN
      dt = (M[ROnSet[n]] - M[ROnSet[n]-dstep]) / dstep

      for i = 2:1:limit
          if ROnSet[n] + dstep + i < N
            dtn = (M[ROnSet[n]-i] - M[ROnSet[n]-i-dstep]) / dstep
            if (dtn * dt) < 0 && dtn < 0
	     # println(Q)
              push!(Q, ROnSet[n]-i)
              break
            end
            dt = copy(dtn)
          end
      end
    end

    # Szukanie S
    ROffSetN = length(ROffSet)
    #println(ROffSetN)
    
    for n = 1:ROffSetN
      dt = (M[ROffSet[n]+dstep] - M[ROffSet[n]]) / dstep

      for i = 2:1:limit
          if ROffSet[n] + dstep + i < N
            dtn = (M[ROffSet[n]+dstep+i] - M[ROffSet[n]+i]) / dstep
            if (dtn * dt) < 0 && dtn > 0
	      #println(S)
              push!(S, (ROffSet[n]+i))
              break
            end
            dt = copy(dtn)
          end
      end
    end

    # Szukanie P
    PN = length(Q)

    for n = 1:PN
      dt = (M[Q[n]+dstep] - M[Q[n]]) / dstep

      # Szukanie POffSet
      for i = 2:1:limit
          if Q[n] - dstep - i < N
            dtn = (M[Q[n]-i] - M[Q[n]-i-dstep]) / dstep
            if (dtn * dt) < 0 && dtn > 0
              POffSet = push!(POffSet, Q[n]-i)
              break
            end
            dt = copy(dtn)
          end
      end

	shift=i    
      dt = (M[Q[n]-shift] - M[Q[n]-dstep-shift]) / dstep

      # Szukanie POnSet
      for i = 2:1:limit
      #if Q[n] + dstep + i < N
        dtn = (M[Q[n]-i] - M[Q[n]-i-dstep]) / dstep
        if (dtn * dt) < 0 && dtn > 0
          POnSet = push!(POnSet, Q[n]-i-shift)
          break
        end
        dt = copy(dtn)
       #end
      end
    end

    # Szukanie T
    TN = length(S)

    for n = 1:TN
      dt = (M[S[n]+dstep] - M[S[n]]) / dstep

      # Szukanie TOnSet
      for i = 2:1:limit
        dtn = (M[S[n]+i+dstep] - M[S[n]+i]) / dstep
        if (dtn * dt) < 0 && dtn < 0
         dtn = (M[S[n]+i+dstep] - M[S[n]+i]) / dstep
          TOnSet = push!(TOnSet, S[n]+i)
          break
        end
        dt = copy(dtn)
      end

      shift=i      
      dt = (M[S[n]+dstep+shift] - M[S[n]+shift]) / dstep

      # Szukanie TOffSet
      for i = 2:1:limit
        dtn = (M[Q[n]+i+dstep+shift] - M[TOnSet[n]+i+shift]) / dstep
        if (dtn * dt) < 0 && dtn < 0
          TOffSet = push!(TOffSet, S[n]+i+shift)
          break
        end
        dt = copy(dtn)
      end
    end

    QRSOnSet = Q
    QRSOffSet = S
    
    return POnSet, POffSet, QRSOnSet, QRSOffSet, TOffSet

end #function

end #module
