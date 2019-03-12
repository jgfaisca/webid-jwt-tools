#!/bin/bash
#
# JWT HTTP server (Token Consumer)
#
# Usage:
# PATH=$PATH:$(pwd)
# consume-jwt.sh
#
# Description:
# Using the nc (Netcat) command for arbitrary TCP
# connections and listens and a named pipe for reading or writing
#
# Note:
# REQUEST and AUTH variables are exported, so the response
# script can parse it
#

# error function
function error(){
  echo "Error: The file $1 was not found."
  exit 1
}

# variables
CONF_DIR="conf"
CONSUMER_CONF="$CONF_DIR/jwt/consumer/consumer.conf"

# read configuration file
[ -r "$CONSUMER_CONF" ] || error "$CONSUMER_CONF"
. $CONSUMER_CONF

export TMP_DIR
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
    export AUTH=
    export REQUEST=
    while read line
    do
      echo $line | head --bytes 2000 >>$LOG_REQ # write request to log file
      line=$(echo "$line" | tr -d '[\r\n]')
      if echo "$line" | grep -qE '^Authorization:'; then # if line starts with "Authorization:"
	AUTH=$line
      fi
      if echo "$line" | grep -qE '^GET /'; then # if line starts with "GET /"
        REQUEST=$(echo "$line" | cut -d ' ' -f2) # extract the request
      elif [ "x$line" = x ]; then # empty line / end of request
        # call response script
        response.sh > $FIFO_OUT &
      fi
    done
  )
done
