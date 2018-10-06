#!/bin/bash

trap "echo Exited!; exit;" SIGINT SIGTERM

while true
do
    $@ || sleep 0.3
done
