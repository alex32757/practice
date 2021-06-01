function value = signal_generator(mSeq, N, tau, frequencyOfSignal, frequencyOfD, amplitude)
    value = [];
    
    for j=1:15
        temp_arr = [];
        temp = mSeq(j,:);
        for i = 1 : N
            temp_arr = [temp_arr, I(2 + (j-1)*0.03 + 1 / frequencyOfSignal * tau * (i - 1), 2 + (j-1)*0.03 + 1 / frequencyOfSignal * tau * i, temp(i), frequencyOfSignal, frequencyOfD, amplitude)];
        end
        value = [value; temp_arr];
    end
end