#!/bin/bash

PROGRAM='plackup ./Munge-App/bin/app.pl'

$PROGRAM &

wait_for_pid () {
    while [[ -d /proc/$1 ]]; do echo "Waiting for $PROGRAM to end"; sleep 0.5; done;
}

terminate_pid () {
    for i in `pgrep -f "plackup"`; do
        echo "TERMINATE $PROGRAM $i";
        kill $i;
        wait_for_pid $i
   done;
}

while inotifywait -e modify -r ./Munge-App/lib;
    do terminate_pid; sleep 1 && $PROGRAM &
done;
