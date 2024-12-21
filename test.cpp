#include "FuncA.h"
#include <cassert>
#include <chrono>
#include <iostream>

int main() {
    FuncA funcA;
    
    // Перевірка часу виконання
    auto start = std::chrono::high_resolution_clock::now();
    funcA.calculate(0.5);
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> elapsed = end - start;

    std::cout << "Elapsed time: " << elapsed.count() << " seconds" << std::endl;

    // Переконатися, що час виконання знаходиться між 5 і 20 секундами
    assert(elapsed.count() >= 5 && elapsed.count() <= 20);
    
    return 0;
}
