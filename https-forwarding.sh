#!/bin/bash
#
# HTTPS to HTTP forwarding using socat
#
# Dependencies:
# $ sudo apt install socat
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
[ -s "$CONSUMER_CONF" ] || error "$CONSUMER_CONF"
. $CONSUMER_CONF

# log file
[ -f "$LOG_HTTPS" ] && rm -f "$LOG_HTTPS"
touch $LOG_HTTPS

# verbosity level (can be used several times)
[ "$VERBOSE" == "true" ] && V_ARG="-v" || V_ARG=""

# HTTPS -> HTTP
#In this case an SSL/TLS connection to $ADDR_SSL on port $PORT_SSL is piped to the remote host $ADDR on port $PORT.
socat $V_ARG -lf $LOG_HTTPS openssl-listen:$PORT_SSL,bind=$ADDR_SSL,cert=$HOST_CRT,key=$HOST_KEY,verify=0,reuseaddr,fork tcp4:$ADDR:$PORT
