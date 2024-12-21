#include <httplib.h>
#include <iostream>
#include <vector>
#include <cmath>
#include <algorithm>
#include <chrono>

class FuncA {
public:
    double calculate(double x) {
        int n = 100;
        double result = 0;
        for (int i = 1; i <= n; ++i) {
            result += pow(-1, i - 1) * pow(x, i) / i;
        }
        return result;
    }
};

int main() {
    httplib::Server svr;
    FuncA funcA;

    svr.Get("/", [](const httplib::Request &req, httplib::Response &res) {
        std::vector<double> values;
        auto start = std::chrono::high_resolution_clock::now();

        for (double x = 0; x < 10; x += 0.1) {
            values.push_back(funcA.calculate(x));
        }

        std::sort(values.begin(), values.end());

        auto end = std::chrono::high_resolution_clock::now();
        std::chrono::duration<double> elapsed = end - start;
        
        res.set_content("Elapsed time: " + std::to_string(elapsed.count()) + " seconds", "text/plain");
    });

    svr.listen("0.0.0.0", 8080);
}
