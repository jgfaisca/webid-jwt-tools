#!/bin/bash
#
# Build the HTTP server response
#
#

export PYTHONIOENCODING=utf8

IPFS_GW="http://127.0.0.1:8080"
LOG_REQ="/tmp/requests.log"
DATADIR="$HOME/.namecoin"

LAST_LINE_REQ=$(cat $LOG_REQ | tail -2)
access_token=$(echo $LAST_LINE_REQ | awk '{print $3}' | xargs)

# Stripping the JWT parts Header.Payload.Signature into an array
declare -a jwt
IFS='.' read -r -a jwt <<< "$access_token"

echo -e "HTTP/1.1 200 OK\r"
echo "Content-type: text/html"
echo

elements="${#jwt[@]}"
if [ $elements -ne 3 ] ; then
   echo "invalid token!"
   exit 1
fi

header=$(echo "${jwt[0]}" | base64 -d)
payload=$(echo "${jwt[1]}" |base64 -d)
signature=$(echo "${jwt[2]}" | base64 -d)
message="$header.$payload"

# get the iss value
iss=$(echo $payload | python -c "import sys, json; print json.load(sys.stdin)['iss']")
if [ $? -ne 0 ]; then
    echo "token doesn't contain the 'iss' value!"
    exit 1
fi

# get the uri value from NMC
nshow=$(namecoin-cli -datadir=$DATADIR name_show "$iss")
out1=$(echo $nshow | python -c "import sys, json; print json.load(sys.stdin)['value']")
uri=$(echo $out1 | python -c "import sys, json; print json.load(sys.stdin)['uri']")

# get profile document from IPFS
tmpfile=$(mktemp /tmp/profile_XXXXXX)
curl -o $tmpfile ${IPFS_GW}${uri}

# use SPARQL to get person name from profile
name=$(sparql-triples-person.py $tmpfile)

# use SPARQL to get wallet address from profile
wallet=$(sparql-triples-wallet.py $tmpfile)

# remove temporary file
rm -f $tmpfile

# verify signature
verify=$(namecoin-cli -datadir=$DATADIR verifymessage $wallet $signature $message)

if [ "$verify" == "true" ]; then
	echo "Hello $name, you have successfully logged in!"
	exit 0
  else
	echo "Authentication failed!"
	exit 1
fi

exit 0
