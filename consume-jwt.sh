#!/bin/bash
#
# JWT HTTP server (Token Consumer)
#
# Usage:
# PATH=$PATH:$(pwd)
# consume-jwt.sh
#
# Description:
# Using the ncat (Nmap/Netcat) command for arbitrary TCP
# connections and listens and a named pipe for reading
# or writing. The ncat command provide SSL-support.
#
# Dependencies:
# $ apt-get install nmap
#
# Note:
# REQUEST and AUTH variables are exported, so the response
# script can parse it
#

function finish {
  rm -f $FIFO_OUT"
  pkill ncat
  pkill socat
}
trap finish EXIT

# error function
function error(){
  echo "Error: The file $1 was not found."
  exit 1
}

# variables
CONF_DIR="conf"
CONSUMER_CONF="$CONF_DIR/jwt/consumer/consumer.conf"

# read configuration file
[ -s "$CONSUMER_CONF" ] || error "$CONSUMER_CONF"
. $CONSUMER_CONF

# export variables
export TMP_DIR
export LOG_REQ

# create log file(s)
[ -f "$LOG_REQ" ] && rm -f "$LOG_REQ"
touch $LOG_REQ

# create named pipe
[ -p "$FIFO_OUT" ] && rm -f "$FIFO_OUT"
mkfifo $FIFO_OUT

# ncat command
CMD="ncat --listen $ADDR $PORT"
# nc command
#CMD="nc -l -q 0 -s $ADDR -p $PORT"

# access control
if [[ ! -z "$ALLOW_FILE" && -s "$ALLOW_FILE" ]]; then
   CMD+=" --allowfile $ALLOW_FILE"
fi

# verbosity level (can be used several times)
if [ "$VERBOSE" == "true" ]; then
   CMD+=" --verbose"
fi

# enable SSL/TLS
if [ "$SSL" == "true" ] ; then
   [ -s "$HOST_CRT" ] || error "$HOST_CRT"
   [ -s "$HOST_KEY" ] || error "$HOST_KEY"
   https-forwarding.sh &
fi

while true
do
    cat $FIFO_OUT | $CMD > >(
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

exit 0
