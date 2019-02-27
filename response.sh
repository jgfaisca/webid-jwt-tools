#!/bin/bash
#
# Build the HTTP server response
#
#

# respond with the HTTP 200 (OK) status code
code_200(){
   echo -e 'HTTP/1.1 200 OK\r'
   echo 'Date: $(date)'
   echo 'Content-type: text/html; charset=UTF-8'
   echo 'Allow: GET'
   echo
}

# respond with the HTTP 400 (Bad Request) status code
code_400(){
   echo -e 'HTTP/1.1 400 Bad Request\r'
   echo "WWW-Authenticate: Bearer realm='example', error='invalid_request', error_description='$1'"
   echo 'Content-type: text/html; charset=UTF-8'
   echo
}

# respond with the HTTP 401 (Unauthorized) status code
code_401(){
   echo -e 'HTTP/1.1 401 Unauthorized\r'
   echo 'WWW-Authenticate: Bearer realm="example", error="invalid_token", error_description="$1"'
   echo 'Content-type: text/html; charset=UTF-8'
   echo
}

# respond with the HTTP 403 (Forbidden) status code
code_403(){
   echo -e 'HTTP/1.1 403 Forbidden\r'
   echo 'WWW-Authenticate: Bearer realm="example", error="insufficient_scope", error_description="$1"'
   echo "Content-type: text/html; charset=UTF-8"
   echo
}

# status code 200 HTML response
response_200(){
	cat <<- _EOF_
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
   <title>Protected Resource</title>
</head>
<body>
   <h3>Success!</h3>
   <p>Hello $1, you logged in.</p>
</body>
</html>
	_EOF_
}

# status code 403 HTML response
response_403(){
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
}

export PYTHONIOENCODING=utf8

IPFS_GW="http://127.0.0.1:8080"
LOG_REQ="/tmp/requests.log"
NMC_DATA_DIR="$HOME/.namecoin"

LAST_LINE_REQ=$(cat $LOG_REQ | tail -2)
header1=$(echo $LAST_LINE_REQ | awk '{print $1}' | xargs)
header2=$(echo $LAST_LINE_REQ | awk '{print $2}' | xargs)

if [ "$header1" != "Authorization:" ] || [ "$header2" != "Bearer" ]; then
   code_400 "request without authentication"
   echo "400 (Bad Request)"
   exit 1
fi

access_token=$(echo $LAST_LINE_REQ | awk '{print $3}' | xargs)

# Stripping the JWT parts Header.Payload.Signature into an array
declare -a jwt
IFS='.' read -r -a jwt <<< "$access_token"

# verify token
elements="${#jwt[@]}"
if [ $elements -ne 3 ] ; then
   code_400 "malformed"
   echo "400 (Bad Request)"
   exit 1
fi

# JWT decode 
header=$(echo "${jwt[0]}" | base64 -i -d)
payload=$(echo "${jwt[1]}" |base64 -i -d)
signature=$(echo "${jwt[2]}" | base64 -i -d)
message="$header.$payload"

# get the iss value
iss=$(echo $payload | python -c "import sys, json; print json.load(sys.stdin)['iss']")
if [ $? -ne 0 ]; then
    code_400 "token missing iss value"
    echo "400 (Bad Request)"
    exit 1
fi

# get the exp value
exp=$(echo $payload | python -c "import sys, json; print json.load(sys.stdin)['exp']")
if [ $? -eq 0 ]; then # token contains the 'exp' value"
    now=$(date +%s) # current time
    if [ $exp -le $now ]; then 
	code_401 "expired token"
    	echo "401 (Unauthorized)"
	exit 1
    fi	
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
	code_200
	response_200 "$name"
  else
	code_403 "not authorized"
  	response_403
fi

exit 0
