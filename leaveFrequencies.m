% A filter which leaves only frequencies between  lowerFreq  and higherFreq from
% the signal.
% Inputs: data - the signal
%                   rate - its sampling rate (in Hz)
%                   lowerFreq - in Hz
%                   higherFreq - in Hz.

function f = leaveFrequencies(data,rate,lowerFreq, higherFreq)
assert(lowerFreq < higherFreq && lowerFreq < rate, 'leaveFrequencies: inappropriate input provided')

m = nanmean(data) ;
data = data - m ;
Y = fft(data) ;
Y(1) = 0;
%Y = abs(fft(data)) ;
N = length(Y)-1;
half = floor(N/2) ;

lowerIndex = floor(lowerFreq*N/rate) ;
higherIndex = ceil(higherFreq*N/rate) ;

if lowerIndex <= 0
  lowerIndex = 1;
end;
if higherIndex < 2
  f = 0;
  warning('removeFrequencies: Length of the input data inappropriate for such filtering');
  return;
end;
if higherIndex > half && mod(length(data),2)
  higherIndex = half;
elseif higherIndex > half
  higherIndex = half+1;
end;

Y(2:lowerIndex) = 0;
Y(end-(lowerIndex-2):end) = 0;
if half >= higherIndex+1
  Y(higherIndex+1:half) = 0;
  Y(half:end-higherIndex+1) = 0;
end;

f = ifft(Y);
f = f + m ;
