#!/bin/bash

while true; do
    curl http://localhost &
    sleep $((RANDOM % 6 + 5))
done
