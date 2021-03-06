%impulse generation
function impulse = I(tStart, tEnd, sign, frequencyOfSignal, frequencyOfDiscret, a)
    time = tStart: 1 / frequencyOfDiscret : (tEnd - (1 / frequencyOfDiscret));
    impulse = a * (-1) * power(-1, sign) * sin(2 * pi * frequencyOfSignal * time);
end
