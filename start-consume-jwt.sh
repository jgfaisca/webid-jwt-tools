#!/bin/bash
#
# Start consume-jwt
#

LOG_FILE="/tmp/http.log"
PATH=$PATH:$(pwd)

nohup consume-jwt.sh > $LOG_FILE &

sleep 2

# print socat pid
PID=$(pgrep socat)
echo $PID

# print ncat pid
PID=$(pgrep ncat)
echo $PID

