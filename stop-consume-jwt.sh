#!/bin/bash
#
# Stop consume-jwt
#

kill_process(){
 if [[ ! -z "$1" && "$1" -gt 0 ]]; then
   CMD="kill $1"
   echo $CMD
   eval $CMD
 fi
}

# kill socat
PID=$(pgrep socat)
kill_process $PID

# kill ncat
PID=$(pgrep ncat)
kill_process $PID

