#!/bin/bash
#
# Decode JWT and validate signature
# Using the Linux Bash base64 command and the jq utility
# (JSON processor for shell) https://stedolan.github.io/jq/
#

# error function
function error(){
  code=$1
  [ $code -eq 1 ] && echo "File not found."
  [ $code -eq 2 ] && echo "Wrong number of JWT elements ($elements)"
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

# Print the jwt array
#for index in "${!jwt[@]}"
#do
#    echo "$index ${jwt[index]}"
#done

# unencode header 
header=$(echo "${jwt[0]}" | base64 -d)

# unencode payload
payload=$(echo "${jwt[1]}" |base64 -d)

# unencode signature
signature=$(echo "${jwt[2]}" | base64 -d)

# create message
message="$header.$payload"

# print unencoded JWT
#echo "$header.$payload.$signature"

# validate 
OUT=$(namecoin-cli -datadir=$DATA_DIR verifymessage ${NMC_ADDRESS} ${signature} ${message})
echo $OUT
