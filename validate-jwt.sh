#!/bin/bash
#
# Usage:
# ./validate.jwt <namecoin_address>
#
# Description:
# This script decode JWT and validate signature
# Using the base64 command for decoding
#

# error function
function error(){
  code=$1
  [ $code -eq 1 ] && echo "Error: File not found."
  [ $code -eq 2 ] && echo "Error: Wrong number of JWT elements ($elements)"
  exit 1
}

# check arguments
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
FILE1="access_token"

# read access_token
[ -f $FILE1 ] && access_token=$(cat $FILE1) || error 1

# stripping the JWT parts header.payload.signature into an array
declare -a jwt
IFS='.' read -r -a jwt <<< "$access_token"
elements="${#jwt[@]}"
[ $elements -ne 3 ] && error 2

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
echo $(namecoin-cli -datadir=$DATA_DIR verifymessage ${NMC_ADDRESS} ${signature} "${message}")

exit 0

