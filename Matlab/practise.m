polynom = [1, 1, 0, 0, 1];
registers = [1, 1, 1, 1];
frequencyOfSignal = 5000;
frequencyOfD = 44100;
tau = 10;
SNR = 20;
amplitude = 1;
powerOfPoly = 4;
N = power(2, powerOfPoly) - 1;
mSeq = m_generator(polynom, registers, powerOfPoly, 0);
countOfMeasurement = 2 * frequencyOfD + 1;
%генерация шума
valueBeforeSignal = zeros(1, countOfMeasurement);
valueBeforeSignal = awgn(valueBeforeSignal, SNR);
valueAfterSignal = zeros(1, countOfMeasurement);
valueAfterSignal = awgn(valueAfterSignal, SNR);
value = [];
for i = 1:N
    value = [value, I(2 + 1 / frequencyOfSignal * tau * (i - 1), 2 + 1 / frequencyOfSignal * tau * i, mSeq(i), frequencyOfSignal, frequencyOfD, amplitude)];
end
%value = [value, amplitude * power(-1, mSeq(N)) * sin(2 * pi * frequencyOfSignal * (2 + 1 / frequencyOfSignal * tau * N))];
%наложение шума на сигнал
value = awgn(value, SNR);
resultSignal = [valueBeforeSignal, value, valueAfterSignal];
%нормирование
maxValueOfSignal = max(abs(resultSignal));
resultSignal = resultSignal / maxValueOfSignal;
t = 0:1/frequencyOfD:4+0.03;
t = t(1:length(resultSignal));
plot(t, resultSignal)
audiowrite('output.wav', resultSignal, frequencyOfD);
