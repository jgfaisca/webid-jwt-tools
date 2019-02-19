#!/bin/bash
#
# JWT HTTP server (Token Receiver)
#
#

LOG_REQ="/tmp/requests" # requests log
FIFO="/tmp/fifo_out" # named pipe
PORT=8888 # port
export LOG_REQ

echo "Serving HTTP on 0.0.0.0 port $PORT ..."

# create log file
[ -d "$LOG_REQ" ] && rm -rf "$LOG_REQ" 
mkdir -p $LOG_REQ

# create named pipe
[ -p "$FIFO_OUT" ] && rm -f "$FIFO_OUT" 
mkfifo $FIFO_OUT
trap "rm -f $FIFO_OUT" EXIT

while true
do
  cat $FIFO_OUT | nc -l -p $PORT > >( # parse the netcat output, to build the answer redirected to the named pipe "out".
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
