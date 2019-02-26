#!/bin/bash
#
# JWT Authentication
# (produce and send JWT)
#

# chech arguments
if [ $# -ne 2 ]; then
  echo
  echo "Invalid number of arguments."
  echo "Usage: ./$(basename "$0") <host> <port>"
  echo
  exit 1
fi

# variables
HOST=$1
PORT=$2

PRODUCE="./produce-jwt.sh"
SEND="./send-jwt.sh"

eval '"$PRODUCE"' && eval '"$SEND"' $HOST $PORT || exit 1
