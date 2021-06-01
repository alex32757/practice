keySet = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15];
valueSet = {'A', 'L', 'E', 'K', 'S', 'N', 'D', 'R', '-', '-', '-', '-', '-', '-', '-'};
M = containers.Map(keySet,valueSet);
%1+x^1+x^4
polynom = [1, 1, 0, 0, 1];
registers = [1, 1, 1, 1];
frequencyOfSignal = 5000;
frequencyOfD = 44100;
tau = 10;
SNR = 7;
amplitude = 1;
powerOfPoly = 4;
N = power(2, powerOfPoly) - 1;
Nfft = 4096;

mSeq = [];
for i=0:14
   mSeq = [mSeq; m_generator(polynom, registers, powerOfPoly, i)]; 
   mSeq(i+1,:);
end

countOfMeasurement = 2 * frequencyOfD + 1;
%noise generation
valueBeforeSignal = zeros(1, countOfMeasurement);
valueBeforeSignal = awgn(valueBeforeSignal, SNR);
valueAfterSignal = zeros(1, countOfMeasurement);
valueAfterSignal = awgn(valueAfterSignal, SNR);

values = signal_generator(mSeq, N, tau, frequencyOfSignal, frequencyOfD, amplitude);
value = [];
value = [value, values(1,:)];
value = [value, values(2,:)];
value = [value, values(3,:)];
value = [value, values(4,:)];
value = [value, values(5,:)];
value = [value, values(1,:)];
value = [value, values(6,:)];
value = [value, values(7,:)];
value = [value, values(8,:)];


%noise overlay
valueDuringSignal = awgn(value, SNR);
resultSignal = [valueBeforeSignal, valueDuringSignal, valueAfterSignal];
%signal normalization
maxValueOfSignal = max(abs(resultSignal));
resultSignal = resultSignal / maxValueOfSignal;

%output
t = 0 : 1/frequencyOfD : 4 + 0.27;
t = t(1 : length(resultSignal));
figure
plot(t, resultSignal)
title('Generated signal') 
xlabel('t, seconds')
audiowrite('output.wav', resultSignal, frequencyOfD);

%--------------------------------------------------------------------------
G0 = [];
F0 = [];
for i = 1 : 15
   tmp = [values(i,:), zeros(1, Nfft - length(values(i,:)))];
   tmp = fft(tmp);
   F0 = [F0; tmp];
end
resultSignalForDetect = [resultSignal, zeros(1, Nfft - mod(length(resultSignal), Nfft))];
iter = length(resultSignalForDetect)/Nfft;

G = [];
for i = 0 : (iter - 1) * 2
    R_max = 0;
    for j = 1 : 15
        G = [];
        U = resultSignalForDetect((i/2 * Nfft + 1) : ((i/2 + 1) * Nfft));
        F = fft(U);
        Fvkf = F .* conj(F0(j,:));
        Fvkf(Nfft/2 + 1 : Nfft) = 0 ;
        R = ifft(Fvkf, 'symmetric');
        R = R(1 : Nfft/2);
        G = [G, R.^2];
        if max(G) > R_max
            R_max = max(G);
            max_j = j;
        end
    end
    if R_max > 40000
        M(max_j)
    end
end


