%1+x^1+x^4
polynom = [1, 1, 0, 0, 1];
registers = [1, 1, 1, 1];
frequencyOfSignal = 5000;
frequencyOfD = 44100;
tau = 10;
SNR = 6;
amplitude = 1;
powerOfPoly = 4;
N = power(2, powerOfPoly) - 1;

%-------------------signal generation--------------------------------------
mSeq = m_generator(polynom, registers, powerOfPoly, 0);
countOfMeasurement = 2 * frequencyOfD + 1;
%noise generation
valueBeforeSignal = zeros(1, countOfMeasurement);
valueBeforeSignal = awgn(valueBeforeSignal, SNR);
valueAfterSignal = zeros(1, countOfMeasurement);
valueAfterSignal = awgn(valueAfterSignal, SNR);
value = [];
for i = 1 : N
    value = [value, I(2 + 1 / frequencyOfSignal * tau * (i - 1), 2 + 1 / frequencyOfSignal * tau * i, mSeq(i), frequencyOfSignal, frequencyOfD, amplitude)];
end
%noise overlay
valueDuringSignal = awgn(value, SNR);
resultSignal = [valueBeforeSignal, valueDuringSignal, valueAfterSignal];
%signal normalization
maxValueOfSignal = max(abs(resultSignal));
resultSignal = resultSignal / maxValueOfSignal;
%output
t = 0 : 1/frequencyOfD : 4 + 0.03;
t = t(1 : length(resultSignal));
figure
plot(t, resultSignal)
title('Generated signal') 
xlabel('t, seconds')
saveas(gcf, 'Generated signal', 'png')
audiowrite('output.wav', resultSignal, frequencyOfD);


%--------------------signal detection--------------------------------------
Nfft = 4096;
G0 = [value, zeros(1, Nfft - length(value))];
F0 = fft(G0);

resultSignalForDetect = [resultSignal, zeros(1, Nfft - mod(length(resultSignal), Nfft))];
iter = length(resultSignalForDetect)/Nfft;
G = [];
for i = 0 : (iter - 1) * 2
    U = resultSignalForDetect((i/2 * Nfft + 1) : ((i/2 + 1) * Nfft));
    F = fft(U);
    Fvkf = F .* conj(F0);
    Fvkf(Nfft/2 + 1 : Nfft) = 0 ;
    R = ifft(Fvkf, 'symmetric');
    R = R(1 : Nfft/2);
    G = [G, R.^2];
end    
%output
t = 0 : 1/frequencyOfD : 1/frequencyOfD * (length(G) - 1);
figure
plot(t, G)
title('IRK') 
xlabel('t, seconds')
saveas(gcf, 'IRK', 'png')