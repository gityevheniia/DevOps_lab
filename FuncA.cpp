#include "FuncA.h" 
#include <cmath>

double FuncA::calculate(double x) {
	int n = 10; // Використовуйте n як аргумент у майбутньому 
	double result = 0; 
	for (int i = 1; i <= n; ++i) { 
		result += pow(-1, i - 1) * pow(x, i) / i; } 
	return result; }
