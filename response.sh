#!/bin/bash
#
# Build http server response
#
#

echo -e "HTTP/1.1 200 OK\r"
echo "Content-type: text/html"
echo

LAST_LINE_REQ=$(cat $LOG_REQ | tail -2)
TOKEN=$(echo $LAST_LINE_REQ | awk '{print $3}' | xargs)
echo $TOKEN
