#!/bin/bash

# Логіка запуску контейнера з визначеним CPU
start_container() {
    container_name=$1
    port=$2
    cpu=$3
    docker run -d --name $container_name --cpuset-cpus=$cpu -p $port:8080 yevheniia042/server:latest
}

# Зупинка контейнера
stop_container() {
    container_name=$1
    docker stop $container_name && docker rm $container_name
}

# Перевірка, чи контейнер зайнятий (використовує більше 50% CPU)
check_busy() {
    container_name=$1
    docker stats --no-stream --format "{{.Name}}:{{.CPUPerc}}" | grep "$container_name" | awk -F: '{if ($2 > 50.0) print "busy"}'
}

# Перевірка, чи контейнер без активного навантаження (менше 10% CPU)
check_idle() {
    container_name=$1
    docker stats --no-stream --format "{{.Name}}:{{.CPUPerc}}" | grep "$container_name" | awk -F: '{if ($2 < 10.0) print "idle"}'
}

# Оновлення контейнерів
update_containers() {
    for container in srv1 srv2 srv3; do
        if docker ps -q -f name=$container; then
            docker pull yevheniia042/server:latest  # Завантажуємо останній образ
            docker stop $container  # Зупиняємо працюючий контейнер
            docker rm $container    # Видаляємо контейнер
            # Призначаємо CPU 0 або CPU 1 по черзі
            if [ "$container" == "srv1" ]; then
                start_container $container 8081 0
            elif [ "$container" == "srv2" ]; then
                start_container $container 8082 1
            elif [ "$container" == "srv3" ]; then
                start_container $container 8083 0
            fi
        fi
    done
}

# Стартуємо перший контейнер
start_container srv1 8081 0

# Основний цикл
while true; do
    if check_busy srv1; then
        if ! docker ps -q -f name=srv2; then
            start_container srv2 8082 1
        elif check_busy srv2 && ! docker ps -q -f name=srv3; then
            start_container srv3 8083 0
        fi
    elif docker ps -q -f name=srv3 && check_idle srv3; then
        stop_container srv3
    elif docker ps -q -f name=srv2 && check_idle srv2; then
        stop_container srv2
    fi

    sleep 120

    # Оновлення контейнерів, якщо є нова версія
    update_containers
done

