#!/bin/bash

PROGRAM='./Munge-App/bin/app.pl'

$PROGRAM &

terminate_pid () {
    for i in `pgrep -f "$PROGRAM"`; do
        echo "TERMINATE $PROGRAM $i";
        kill $i;
        wait $i;
   done;
}

while inotifywait -e modify -r ./Munge-App/lib;
    do terminate_pid; sleep 1 && $PROGRAM &
done;
