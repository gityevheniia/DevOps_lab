#!/bin/bash

while true; do
    curl -s http://127.0.0.1/ &
    sleep $((RANDOM % 6 + 5))
done
