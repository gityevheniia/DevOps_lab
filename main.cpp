#include <iostream>
#include "FuncA.h"

int main() {
    FuncA funcA;
    double result = funcA.calculate(0); // Виклик функції з аргументом 0
    std::cout << "Result: " << result << std::endl;
    return 0;
}
