#include "FuncA.h"
#include <cmath>

double FuncA::calculate(double x) {
	double result = 0; 
	for (int i = 1; i <= 3; ++i) { 
		result += pow(-1, i - 1) * pow(x, i) / i;
 	} 
return result; 
}

