%m-sequence generation
function m_seq = m_generator(polynom, registers, n, k)
    for i = n:(power(2, n) - 2)
        registers(end + 1) = 0;
        for j = 1:n
            registers(end) = xor(registers(end), polynom(j + 1) * registers(i - j + 1));
        end
    end
    m_seq = registers;
end
