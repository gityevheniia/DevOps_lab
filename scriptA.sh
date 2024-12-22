#!/bin/bash

start_container() {
    container_name=$1
    port=$2
    cpu=$3
    docker run -d --name $container_name --cpuset-cpus=$cpu -p $port:8080 yevheniia042/server:latest
}

stop_container() {
    container_name=$1
    docker stop $container_name && docker rm $container_name
}

check_busy() {
    container_name=$1
    docker stats --no-stream --format "{{.Name}}:{{.CPUPerc}}" | grep "$container_name" | awk -F: '{if ($2 > 50.0) print "busy"}'
}

check_idle() {
    container_name=$1
    docker stats --no-stream --format "{{.Name}}:{{.CPUPerc}}" | grep "$container_name" | awk -F: '{if ($2 < 10.0) print "idle"}'
}

update_containers() {
    for container in srv1 srv2 srv3; do
        if docker ps -q -f name=$container; then
            docker pull yevheniia042/server:latest
            docker stop $container
            docker rm $container
            start_container $container 808$((RANDOM%3+1)) $((RANDOM%3))
        fi
    done
}

# Start the first container
start_container srv1 8081 0

while true; do
    if check_busy srv1; then
        if ! docker ps -q -f name=srv2; then
            start_container srv2 8082 1
        elif check_busy srv2 && ! docker ps -q -f name=srv3; then
            start_container srv3 8083 2
        fi
    elif docker ps -q -f name=srv3 && check_idle srv3; then
        stop_container srv3
    elif docker ps -q -f name=srv2 && check_idle srv2; then
        stop_container srv2
    fi

    sleep 120

    # Update containers if a new version is available
    update_containers
done
