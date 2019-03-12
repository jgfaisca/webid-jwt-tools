#!/bin/bash
#
# JWT Authentication
# (produce and send JWT)
#

# chech arguments
if [ $# -ne 1 ]; then
  echo
  echo "Invalid number of arguments."
  echo "Usage: ./$(basename "$0") <uri>"
  echo
  exit 1
fi

# variables
URI=$1

PRODUCE="./produce-jwt.sh"
SEND="./send-jwt.sh"

eval '"$PRODUCE"' && eval '"$SEND"' $URI || exit 1
