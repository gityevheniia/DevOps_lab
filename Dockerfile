FROM ubuntu:20.04

# Set environment variable to avoid tzdata prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install tzdata and set the time zone to Kyiv, Ukraine
RUN apt-get update && apt-get install -y tzdata && \
    ln -fs /usr/share/zoneinfo/Europe/Kiev /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

# Install necessary dependencies
RUN apt-get install -y build-essential git cmake libssl-dev wget

# Copy project files
COPY . /app
WORKDIR /app

# Compile the server
RUN g++ -o server server.cpp -std=c++17 -pthread

# Expose port
EXPOSE 8080

CMD ["./server"]

