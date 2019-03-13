
#!/bin/bash
#
# Send JWT on the HTTP Authorization header 
#

# error function
function error(){
  echo "Error: The file $1 was not found."
  exit 1
}

# chech arguments
if [ $# -ne 1 ]; then
  echo
  echo "Invalid number of arguments."
  echo "Usage: ./$(basename "$0") <url>"
  echo
  exit 1
fi

TMP_DIR="./tmp"
[ -r "$TMP_DIR/access_token" ] && JWT=$(cat $TMP_DIR/access_token) || error "$TMP_DIR/access_token"
URL="$1"

[[ $URL == https://* ]] && ARG="--insecure" || ARG=""

curl -v $ARG -H "Authorization: Bearer ${JWT}" ${URL} || printf '%s\n' $?
