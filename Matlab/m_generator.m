%m-sequence generation
function m_seq = m_generator(polynom, registers, n, k)
    size = power(2, n) - 1;

    for i = n:(size - 1)
        registers(end + 1) = 0;
        for j = 1:n
            registers(end) = xor(registers(end), polynom(j + 1) * registers(i - j + 1));
        end
    end
    
    k = mod(k, size);
    new_reg = circshift(registers, k);
    
    m_seq = new_reg;
end
