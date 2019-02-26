#!/bin/bash
#
# Usage:
# ./validate.jwt <wallet_address>
#
# Description:
# This script decode JWT and validate signature
# Using the base64 command for decoding
#

# error1 function
function error1(){
  echo "Error: File $1 not found."
  exit 1
}

# error2 function
function error2(){
  echo "Error: Wrong number of JWT elements ($elements)"
  exit 1
}

# check arguments
if [ $# -ne 1 ]; then
  echo
  echo "Invalid number of arguments."
  echo "Usage: ./$(basename "$0") <wallet_address>"
  echo
  exit 1
fi

TMP_DIR="tmp/jwt"
CONF_DIR="conf"
DLT_CONF_FILE="$CONF_DIR/dlt/wallet.conf"

# read configuration file(s)
[ -r "$DLT_CONF_FILE" ] || error1 "$DLT_CONF_FILE"
. $DLT_CONF_FILE

# read wallet address 
WALLET_ADDRESS_FILE="$TMP_DIR/wallet_address"
[ -r $WALLET_ADDRESS_FILE ] && wallet_address=$(cat $WALLET_ADDRESS_FILE) || error1 $WALLET_ADDRESS_FILE 

# read access_token
ACCESS_TOKEN_FILE="$TMP_DIR/access_token"
[ -r $ACCESS_TOKEN_FILE ] && access_token=$(cat $ACCESS_TOKEN_FILE) || error1 $ACCESS_TOKEN_FILE 

# stripping the JWT parts header.payload.signature into an array
declare -a jwt
IFS='.' read -r -a jwt <<< "$access_token"
elements="${#jwt[@]}"
[ $elements -ne 3 ] && error2

# print the jwt array
#for index in "${!jwt[@]}"
#do
#    echo "$index ${jwt[index]}"
#done

# decode header.payload.signature 
header=$(echo "${jwt[0]}" | base64 -d)
payload=$(echo "${jwt[1]}" |base64 -d)
signature=$(echo "${jwt[2]}" | base64 -d)
#echo "$header.$payload.$signature"

# create message
message="$header.$payload"

# validate 
echo $(namecoin-cli -datadir=$NMC_DATA_DIR verifymessage ${NMC_ADDRESS} ${signature} "${message}")

exit 0

