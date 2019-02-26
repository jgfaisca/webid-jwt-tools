#!/bin/bash
#
# Build the HTTP server response
#
#

export PYTHONIOENCODING=utf8

IPFS_GW="http://127.0.0.1:8080"
LOG_REQ="/tmp/requests.log"
NMC_DATA_DIR="$HOME/.namecoin"

LAST_LINE_REQ=$(cat $LOG_REQ | tail -2)
access_token=$(echo $LAST_LINE_REQ | awk '{print $3}' | xargs)

# Stripping the JWT parts Header.Payload.Signature into an array
declare -a jwt
IFS='.' read -r -a jwt <<< "$access_token"

echo -e "HTTP/1.1 200 OK\r"
echo "Content-type: text/html"
echo "Allow: GET"
echo

elements="${#jwt[@]}"
if [ $elements -ne 3 ] ; then
   echo "invalid token!"
   exit 1
fi

header=$(echo "${jwt[0]}" | base64 -i -d)
payload=$(echo "${jwt[1]}" |base64 -i -d)
signature=$(echo "${jwt[2]}" | base64 -i -d)
message="$header.$payload"

# get the iss value
iss=$(echo $payload | python -c "import sys, json; print json.load(sys.stdin)['iss']")
if [ $? -ne 0 ]; then
    echo "token doesn't contain the 'iss' value!"
    exit 1
fi

# get the uri value from NMC
nshow=$(namecoin-cli -datadir=$NMC_DATA_DIR name_show "$iss")
out1=$(echo $nshow | python -c "import sys, json; print json.load(sys.stdin)['value']")
uri=$(echo $out1 | python -c "import sys, json; print json.load(sys.stdin)['uri']")

# get profile document from IPFS
tmpfile=$(mktemp /tmp/profile_XXXXXX)
curl --silent --output $tmpfile ${IPFS_GW}${uri}

# use SPARQL to get person name from profile
name=$(sparql-triples-person.py $tmpfile)

# use SPARQL to get wallet address from profile
address=$(sparql-triples-wallet.py $tmpfile)

# remove temporary file
rm -f $tmpfile

# verify signature
verify=$(namecoin-cli -datadir=$NMC_DATA_DIR verifymessage $address $signature "$message")

if [ "$verify" == "true" ]; then
	cat <<- _EOF_
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
   <title>Protected Resource</title>
</head>
<body>
   <h3>Success!</h3>
   <p>Hello $name, you logged in.</p>
</body>
</html>
	_EOF_
  else
  	cat <<- _EOF_
 <!DOCTYPE html>
 <html>
 <head>
 <meta charset="UTF-8">
    <title>Failed Login Attempt</title>
 </head>
 <body>
    <h3>Authentication Error!</h3>
    </p>Please check your user id and and try again.</p>
 </body>
 </html>
	_EOF_
fi

exit 0
