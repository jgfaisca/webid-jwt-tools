
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
if [ $# -ne 2 ]; then
  echo
  echo "Invalid number of arguments."
  echo "Usage: ./$(basename "$0") <host> <port>"
  echo
  exit 1
fi

TMP_DIR="./tmp"
[ -r "$TMP_DIR/access_token" ] && JWT=$(cat $TMP_DIR/access_token) || error "$TMP_DIR/access_token"
HOST="$1"
PORT="$2"

curl -v -H "Authorization: Token ${JWT}" ${HOST}:${PORT} || printf '%s\n' $?
