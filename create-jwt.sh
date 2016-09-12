#!/bin/bash
#
# Create the JWT
#

NMC_ADDRESS="$1"
#DATADIR="$HOME/.namecoin"
DATA_DIR="/data/namecoin"
FILE1="header_payload"
FILE2="unencoded_token"
FILE3="access_token"
WALLET_PW="secret"

function error(){
  code=$1
  [ $code -eq 1 ] && echo "File not found."
  [ $code -eq 2 ] && echo "Wrong number of JWT elements ($elements)"
  exit 1
}

if [ $# -ne 1 ]; then
  echo
  echo "Invalid number of arguments."
  echo "Usage: ./$(basename "$0") <namecoin_address>"
  echo
  exit 1
fi

# check file
[ ! -f $FILE1 ] && error 1

header=$(awk 'NR==1' $FILE1)
payload=$(awk 'NR==2' $FILE1)

# get message
message=$header.$payload

# unlock wallet for 10 seconds
namecoin-cli -datadir=$DATA_DIR walletpassphrase "${WALLET_PW}" 10 &&

# sign
signature=$(namecoin-cli -datadir=$DATA_DIR signmessage "${NMC_ADDRESS}" "${message}") &&

unencoded_token="$message.$signature"
echo $unencoded_token > $FILE2

# Stripping the JWT parts Header.Payload.Signature into an array
declare -a ujwt

[ -f $FILE3 ] && rm -f $FILE3
touch $FILE3

# Encode
enc="$(echo -n "$header" | base64 | tr -d '\n')"
enc="$enc.$(echo "$payload" | base64 | tr -d '\n')"
enc="$enc.$(echo "$signature" | base64 | tr -d '\n')"

echo $enc > $FILE3

cat $FILE3
