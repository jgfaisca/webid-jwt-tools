#!/bin/bash
#
# Usage:
# ./create_jwt.sh <issuer>
# 
# Example:
# ./create_jwt.sh id/bob
#
# Description:
# This script creates an JWT 
# Using the base64 command for encoding
#

# error function
function error(){
  code=$1
  [ $code -eq 1 ] && echo "Error: File not found."
  [ $code -eq 2 ] && echo "Error: Wrong number of JWT elements ($elements)"
  exit 1
}

# chech arguments
if [ $# -ne 1 ]; then
  echo
  echo "Invalid number of arguments."
  echo "Usage: ./$(basename "$0") <namespace/name>"
  echo
  exit 1
fi

# variables
iss="$1"
NMC_ADDRESS=""
#DATADIR="$HOME/.namecoin"
DATA_DIR="/data/namecoin"
FILE1="header_payload"
FILE2="unencoded_token"
FILE3="access_token"
WALLET_PW="secret"
UNLOCK_SEC=10

# get address value from NMC
nshow=$(namecoin-cli -datadir=$DATADIR name_show "$iss")
NMC_ADDRESS=$(echo $nshow | python -c "import sys, json; print json.load(sys.stdin)['address']")

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
