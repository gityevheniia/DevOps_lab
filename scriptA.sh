#!/bin/bash

# Start the first container
docker run -d --cpuset-cpus=0 --name srv1 -p 8081:8080 yevheniia042/http_server:optimized

# Monitor and scale up/down containers
while true; do
    # Check CPU usage for srv1
    if [ $(docker stats srv1 --no-stream --format "{{.CPUPerc}}" | awk -F '.' '{print $1}') -gt 80 ]; then
        if ! docker ps --filter "name=srv2" | grep -q srv2; then
            docker run -d --cpuset-cpus=1 --name srv2 -p 8082:8080 yevheniia042/http_server:optimized
        fi
    fi

    # Check CPU usage for srv2
    if docker ps --filter "name=srv2" | grep -q srv2; then
        if [ $(docker stats srv2 --no-stream --format "{{.CPUPerc}}" | awk -F '.' '{print $1}') -gt 80 ]; then
            if ! docker ps --filter "name=srv3" | grep -q srv3; then
                docker run -d --cpuset-cpus=2 --name srv3 -p 8083:8080 yevheniia042/http_server:optimized
            fi
        elif [ $(docker stats srv2 --no-stream --format "{{.CPUPerc}}" | awk -F '.' '{print $1}') -lt 10 ]; then
            docker stop srv2 && docker rm srv2
        fi
    fi

    # Check CPU usage for srv3
    if docker ps --filter "name=srv3" | grep -q srv3; then
        if [ $(docker stats srv3 --no-stream --format "{{.CPUPerc}}" | awk -F '.' '{print $1}') -lt 10 ]; then
            docker stop srv3 && docker rm srv3
        fi
    fi

    # Check for updates on Docker Hub and update containers
    docker pull yevheniia042/http_server:optimized
    for container in srv1 srv2 srv3; do
        if docker ps --filter "name=$container" | grep -q $container; then
            docker stop $container && docker rm $container
            docker run -d --name $container -p 808$(( ${container:3:1} )):8080 yevheniia042/http_server:optimized
        fi
    done

    sleep 120
done

