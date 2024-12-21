#include <iostream>
#include <cmath>
#include <vector>
#include <algorithm>
#include <chrono>
#include <unistd.h>
#include <string.h>
#include <netinet/in.h>
#include <pthread.h>

// Function to calculate trigonometric values
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

// Function to handle client connections
void* handle_client(void* arg) {
    int client_socket = *(int*)arg;
    FuncA funcA;

    // Array of values to be sent back to the client
    std::vector<double> values;
    auto start = std::chrono::high_resolution_clock::now();

    for (double x = 0; x < 10; x += 0.1) {
        values.push_back(funcA.calculate(x));
    }

    // Sort the array
    std::sort(values.begin(), values.end());

    // Calculate elapsed time
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> elapsed = end - start;

    // Prepare the response
    std::string response = "HTTP/1.1 200 OK\r\n";
    response += "Content-Type: text/plain\r\n";
    response += "Connection: close\r\n\r\n";
    response += "Elapsed time: " + std::to_string(elapsed.count()) + " seconds\n";
    response += "Sorted Values: ";
    for (const auto& val : values) {
        response += std::to_string(val) + " ";
    }
    response += "\n";

    // Send the response
    send(client_socket, response.c_str(), response.size(), 0);
    close(client_socket);

    return nullptr;
}

int main() {
    int server_fd, client_socket;
    struct sockaddr_in server_addr, client_addr;
    socklen_t client_len = sizeof(client_addr);

    // Create socket
    server_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (server_fd < 0) {
        perror("Socket failed");
        exit(EXIT_FAILURE);
    }

    // Set server address
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(8080);

    // Bind the socket
    if (bind(server_fd, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0) {
        perror("Bind failed");
        close(server_fd);
        exit(EXIT_FAILURE);
    }

    // Listen for incoming connections
    if (listen(server_fd, 5) < 0) {
        perror("Listen failed");
        close(server_fd);
        exit(EXIT_FAILURE);
    }

    std::cout << "Server is listening on port 8080..." << std::endl;

    // Accept and handle client connections
    while (true) {
        client_socket = accept(server_fd, (struct sockaddr*)&client_addr, &client_len);
        if (client_socket < 0) {
            perror("Accept failed");
            continue;
        }

        // Create a new thread to handle the client
        pthread_t thread;
        pthread_create(&thread, nullptr, handle_client, (void*)&client_socket);
        pthread_detach(thread);
    }

    // Close the server socket
    close(server_fd);

    return 0;
}

