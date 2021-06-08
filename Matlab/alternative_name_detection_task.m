%create our alphabet
keySet = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15];
valueSet = {'T', 'E', 'S', '_', 'M', 'A', 'G', '-', '-', '-', '-', '-', '-', '-', '-'};
M = containers.Map(keySet,valueSet); 
%initial data
polynom = [1, 1, 0, 0, 1]; %1+x^1+x^4
alternative_polynom = [1, 0, 0, 1, 1]; %1+x^3+x^4
registers = [1, 1, 1, 1];
frequencyOfSignal = 5000;
frequencyOfD = 44100;
tau = 10;
SNR = 6;
amplitude = 1;
powerOfPoly = 4;
N = power(2, powerOfPoly) - 1;
Nfft = 2048;
output_sensitivity = 0.70;

%creating all shifts
mSeq = [];
for i=0:14
   mSeq = [mSeq; m_generator(polynom, registers, powerOfPoly, i)]; 
   mSeq(i+1,:);
end
add_mSeq = m_generator(alternative_polynom, registers, powerOfPoly, 7);
%multiply by another sequence
for i = 1 : 15
    mSeq(i,:) = mSeq(i,:) .* add_mSeq;
end

%noise generation
countOfMeasurement = 2 * frequencyOfD + 1;
valueBeforeSignal = zeros(1, countOfMeasurement);
valueBeforeSignal = awgn(valueBeforeSignal, SNR);
valueAfterSignal = zeros(1, countOfMeasurement);
valueAfterSignal = awgn(valueAfterSignal, SNR);
noiseCount = round(1 / frequencyOfSignal * tau * frequencyOfD * N + 1);
valueBetweenSignal = zeros(1, noiseCount);

% forming a signal
values = signal_generator(mSeq, N, tau, frequencyOfSignal, frequencyOfD, amplitude);
value = [];
value = [value, values(1,:)];
value = [value, values(2,:)];
value = [value, values(3,:)];
value = [value, values(1,:)];
value = [value, values(4,:)];
value = [value, values(5,:)];
value = [value, values(2,:)];
value = [value, values(3,:)];
value = [value, values(3,:)];
value = [value, values(6,:)];
value = [value, values(7,:)];
value = [value, values(2,:)];

%noise overlay
valueDuringSignal = awgn(value, SNR);
resultSignal = [valueBeforeSignal, valueDuringSignal, valueAfterSignal];
%signal normalization
maxValueOfSignal = max(abs(resultSignal));
resultSignal = resultSignal / maxValueOfSignal;

%output
t = 0 : 1/frequencyOfD : 4 + 1 / frequencyOfSignal * tau * N * 12 * 1;
t = t(1 : length(resultSignal));
figure
plot(t, resultSignal)
title('Generated signal') 
xlabel('t, seconds')
saveas(gcf, 'Generated signal', 'png')
audiowrite('output.wav', resultSignal, frequencyOfD);

%----------------signal detection------------------------------------------
F0 = [];
%filters
for i = 1 : 15
   tmp = [values(i,:), zeros(1, Nfft - length(values(i,:)))];
   tmp = fft(tmp);
   F0 = [F0; tmp];
end
resultSignalForDetect = [resultSignal, zeros(1, Nfft - mod(length(resultSignal), Nfft))];
iter = length(resultSignalForDetect)/Nfft;

GMaxGlobal = [];
IndGlobal = [];
for i = 0 : (iter - 1) * 2
    GMax = 0;
    for j = 1 : 15
        G = [];
        U = resultSignalForDetect((i/2 * Nfft + 1) : ((i/2 + 1) * Nfft));
        F = fft(U);
        Fvkf = F .* conj(F0(j,:));
        Fvkf(Nfft/2 + 1 : Nfft) = 0 ;
        R = ifft(Fvkf, 'symmetric');
        R = R(1 : Nfft/2);
        G = [G, R.^2];
        if max(G) > GMax
            GMax = max(G);
            IndGMax = j;
        end
    end
    GMaxGlobal = [GMaxGlobal, GMax];
    IndGlobal = [IndGlobal, IndGMax];
end

%output
res = [];
for i = 1:length(GMaxGlobal)
    if GMaxGlobal(i) > max(GMaxGlobal) * output_sensitivity 
        res = [res, M(IndGlobal(i))];
    end
end
res


