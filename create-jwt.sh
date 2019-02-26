#!/bin/bash
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

# replace a string in an existing file
function replaceVar(){
  VAR1="$1"
  VAR2="$2"
  FILE="$3"
  CMD="perl -pi -e 's|${VAR1}|${VAR2}|g' $FILE"
  eval $CMD
}

# variables
. jwt.conf
iss="$ISSUER"
NMC_ADDRESS=""
#DATADIR="$HOME/.namecoin"
DATA_DIR="/data/namecoin"
FILE0="header.template"
FILE1="payload.template"
FILE2="unencoded_token"
FILE3="access_token"
WALLET_PW="secret"
UNLOCK_SEC=10

# get address value from NMC
nshow=$(namecoin-cli -datadir=$DATA_DIR name_show "$iss")
NMC_ADDRESS=$(echo $nshow | python -c "import sys, json; print json.load(sys.stdin)['address']")

# create message
[ ! -f $FILE0 ] && error 1
[ ! -f $FILE1 ] && error 1
cp $FILE0 header
#header=$(awk -v val="${ALGORITHM}" '{gsub("ALGORITHM",val); print}' $FILE0)
replaceVar "ALGORITHM" ${ALGORITHM} header
#echo $header > header
cp $FILE1 payload
#payload=$(awk -v val="${ISSUER}" '{gsub("ISSUER",val); print}' $FILE1)
replaceVar "ISSUER" "${ISSUER}" payload
#echo $payload > payload
if [ -z "$EXPIRYDATE" ]; then
    DATE=$(perl -e '$x=time+(${HOURS}*3600);print $x')
    #payload=$(awk -v val="${DATE}" '{gsub("EXPIRYDATE",val); print}' payload)
    replaceVar "EXPIRYDATE" "${DATE}" payload
else
    #payload=$(awk -v val="${EXPIRYDATE}" '{gsub("EXPIRYDATE",val); print}' payload)
    replaceVar "EXPIRYDATE" "${EXPIRYDATE}" payload
fi
#echo $payload > payload
header=$(cat header)
payload=$(cat payload)
message=$header.$payload 
echo $message > message

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
