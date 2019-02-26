#!/bin/bash
#
# JWT HTTP server (Token Consumer)
#
# Usage:
# PATH=$PATH:$(pwd)
# consume-jwt.sh [port]
#
# Description:
# Using the nc (Netcat) command for arbitrary TCP 
# connections and listens and a named pipe for reading or writing
#

# variables
LOG_REQ="/tmp/requests.log" # requests log
FIFO_OUT="/tmp/fifo_out" # named pipe
PORT=${1:-8888} # local port number 
ADDR="0.0.0.0" # local source address
export LOG_REQ

# create log file
[ -f "$LOG_REQ" ] && rm -f "$LOG_REQ" 
touch $LOG_REQ

# create named pipe
[ -p "$FIFO_OUT" ] && rm -f "$FIFO_OUT" 
mkfifo $FIFO_OUT
trap "rm -f $FIFO_OUT" EXIT

# print initial console message
echo "Serving HTTP on $ADDR port $PORT ..."

while true
do
  cat $FIFO_OUT | nc -l -q 0 -s $ADDR -p $PORT > >( # parse the netcat output, to build the answer redirected to "fifo_out".
    export REQUEST=
    while read line
    do
      echo $line | head --bytes 2000 >>$LOG_REQ # write request to log file
      line=$(echo "$line" | tr -d '[\r\n]')

      if echo "$line" | grep -qE '^GET /' # if line starts with "GET /"
      then
        REQUEST=$(echo "$line" | cut -d ' ' -f2) # extract the request
      elif [ "x$line" = x ] # empty line / end of request
      then
        # call response script
        # Note: REQUEST is exported, so the script can parse it (to answer 200/403/404 status code + content)
        response.sh > $FIFO_OUT
      fi
    done
  )
done
