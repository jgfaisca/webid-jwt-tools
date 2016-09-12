#!/bin/bash
#
# JWT HTTP server (Token Receiver)
#
#

LOG_REQ="/tmp/requests" # requests log
PORT=8888 # port
export LOG_REQ

echo "Serving HTTP on 0.0.0.0 port $PORT ..."

rm -f $LOG_REQ
rm -f out
mkfifo out
trap "rm -f out" EXIT
while true
do
  cat out | nc -l -p $PORT > >( # parse the netcat output, to build the answer redirected to the pipe "out".
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
        response.sh > out
      fi
    done
  )
done
