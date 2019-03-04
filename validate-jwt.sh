#!/bin/bash
#
# Description:
# This script decode JWT and validate signature
# Using the base64 command for decoding
#

# error1 function
function error1(){
  echo "Error: The file $1 was not found."
  exit 1
}

# error2 function
function error2(){
  echo "Error: Wrong number of JWT elements ($elements)"
  exit 1
}

TMP_DIR="./tmp"
CONF_DIR="conf"
DLT_CONF_FILE="$CONF_DIR/dlt/wallet.conf"

# read configuration file(s)
[ -r "$DLT_CONF_FILE" ] || error1 "$DLT_CONF_FILE"
. $DLT_CONF_FILE

# verify DLT support
if [ $DLT != "namecoin" ]; then 
  echo "$DLT is not supported"
  exit 1
fi

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

# decode header.payload.signature 
header=$(echo "${jwt[0]}" | base64 -d)
payload=$(echo "${jwt[1]}" |base64 -d)
signature=$(echo "${jwt[2]}" | base64 -d)

# create message
message="$header.$payload"

# validate 
echo $(namecoin-cli -datadir=$NMC_DATA_DIR verifymessage ${wallet_address} ${signature} "${message}")

exit 0

