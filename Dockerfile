# Stage 1: Build the application
FROM ubuntu:20.04 AS build

# Set environment variable to avoid tzdata prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y tzdata && \
    ln -fs /usr/share/zoneinfo/Europe/Kiev /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

# Install necessary dependencies for building the app
RUN apt-get install -y build-essential git cmake libssl-dev wget

# Copy the source code into the container
COPY . /app
WORKDIR /app

# Compile the server
RUN g++ -o server server.cpp -std=c++17 -pthread

# Stage 2: Create the runtime image with a smaller base (Alpine)
FROM alpine:latest

# Install necessary runtime dependencies (e.g., for running the server)
RUN apk update && apk add --no-cache libstdc++ # Add only necessary dependencies

# Copy the compiled server binary from the build stage
COPY --from=build /app/server /usr/local/bin/server

# Expose port
EXPOSE 8080

# Start the server
CMD ["server"]

