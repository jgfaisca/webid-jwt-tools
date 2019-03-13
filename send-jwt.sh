
#!/bin/bash
#
# Send JWT on the HTTP Authorization header 
#

# error function
function error(){
  echo "Error: The file $1 was not found."
  exit 1
}

# variables
TMP_DIR="./tmp"
CONF_DIR="conf"
PRODUCER_CONF="$CONF_DIR/jwt/producer/producer.conf"

# read configuration file
[ -r "$PRODUCER_CONF" ] || error "$PRODUCER_CONF"
. $PRODUCER_CONF

# chech arguments
if [ $# -ne 1 ]; then
  echo
  echo "Invalid number of arguments."
  echo "Usage: ./$(basename "$0") <url>"
  echo
  echo "Example:"
  echo "$ ./$(basename "$0") https://example.com:4433"
  echo
  exit 1
fi

# get access_token
[ -r "$TMP_DIR/access_token" ] && JWT=$(cat $TMP_DIR/access_token) || error "$TMP_DIR/access_token"

# check url
URL="$1"
if [[ $SSL = "true" ]] && [[ $URL != https://* ]]; then
    echo "Error: url requires secure connection (https://)"
    exit 1
elif [[ $SSL != "true" ]] && [[ $URL != http://* ]]; then
    echo "Error: url requires insecure connection (http://)"
    exit 1
fi

# ignore invalid and self signed ssl connection errors
[[ $URL == https://* ]] && ARG="--insecure" || ARG=""

# send request
curl -v $ARG -H "Authorization: Bearer ${JWT}" ${URL} || printf '%s\n' $?

exit 0
