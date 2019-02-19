#!/bin/bash
#
# Create the JWT
# Using the Linux Bash base64 command 
#

# error function
function error(){
  code=$1
  [ $code -eq 1 ] && echo "File not found."
  [ $code -eq 2 ] && echo "Wrong number of JWT elements ($elements)"
  exit 1
}

# chech arguments
if [ $# -ne 1 ]; then
  echo
  echo "Invalid number of arguments."
  echo "Usage: ./$(basename "$0") <namecoin_address>"
  echo
  exit 1
fi

# variables
NMC_ADDRESS="$1"
#DATADIR="$HOME/.namecoin"
DATA_DIR="/data/namecoin"
FILE1="header_payload"
FILE2="unencoded_token"
FILE3="access_token"
WALLET_PW="secret"
UNLOCK_SEC=10

# create message
[ ! -f $FILE1 ] && error 1
header=$(awk 'NR==1' $FILE1)
payload=$(awk 'NR==2' $FILE1)
message=$header.$payload

# unlock wallet for n seconds
namecoin-cli -datadir=$DATA_DIR walletpassphrase "${WALLET_PW}" $UNLOCK_SEC &>/dev/null

# sign message
signature=$(namecoin-cli -datadir=$DATA_DIR signmessage "${NMC_ADDRESS}" "${message}") 

# create unencoded_token
unencoded_token="$message.$signature"
echo $unencoded_token > $FILE2

# create access_token 
enc="$(echo -n "$header" | base64 | tr -d '\n')"
enc="$enc.$(echo "$payload" | base64 | tr -d '\n')"
enc="$enc.$(echo "$signature" | base64 | tr -d '\n')"
echo $enc > $FILE3

# print access_token
cat $FILE3

exit 0
