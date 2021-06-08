#include <iostream>
#include <vector>
#include <algorithm>
#include <cmath>

using namespace std;

vector<int> m_seq_generator(vector<int> poly, vector<int> reg, int n, int k) {
    int result = 0;
    int size = (pow(2, n) - 1);

    //формирование последовательности
    for (int i = n; i < size; i++) {
        for (int j = 1; j <= n; j++) {
            result ^= poly.at(j) * reg.at(i - j);
        }
        reg.push_back(result);
        result = 0;
    }

    //ЦВС
    k = k % size;
    int temp;
    while (k--) {
        temp = reg.at(size - 1);
        for (int i = size - 1; i > 0; --i)
            reg.at(i) = reg.at(i - 1);
        reg.at(0) = temp;
    }
    
    return reg;
}

int main() {
    int buffer;
    int n; //порядок последовательноти
    int k; //ЦВС
    vector<int> reg; //начальные регистры

    //порождающие полиномы
    vector<vector<int>> polies = { 
        {1, 1},
        {1, 1, 1},
        {1, 1, 0, 1},
        {1, 1, 0, 0, 1}, //
        {1, 0, 1, 0, 0, 1},
        {1, 1, 0, 0, 0, 0, 1},
        {1, 0, 0, 1, 0, 0, 0, 1},
        {1, 0, 1, 1, 1, 0, 0, 0, 1},
        {1, 0, 0, 0, 1, 0, 0, 0, 0, 1},
        {1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1},
        {1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1},
        {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1}
    };

    cout << "Enter sequence order (1 <= n <= 16): ";
    cin >> n;
    reg.reserve(pow(2, n) - 1);

    for(int i = 0; i < n; i++) {
        cout << "Enter reg[" << i << "]: ";
        cin >> buffer;
        reg.push_back(buffer);
    }
    cout << endl;

    cout << "Enter shift: ";
    cin >> k;
    k = (k < 0) ? k + (pow(2, n) - 1) : k;

    reg = m_seq_generator( polies[n - 1], reg, n, k);

    cout << endl << "Result: ";
    for_each(reg.begin(), reg.end(), [](int i) {
            cout << std::left << i;
        });

    return 0;
}