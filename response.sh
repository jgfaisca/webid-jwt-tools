#!/bin/bash
#
# Build the HTTP server response
#
# respond with the HTTP 200 (OK) status code
#

# error function
function error(){
  echo "Error: The file $1 was not found."
  exit 1
}

# respond with the HTTP 200 (OK) status code
code_200(){
   echo -e "HTTP/1.1 200 OK\r"
   echo "Date: $(date)"
   echo "Content-type: text/html; charset=UTF-8"
   echo "Allow: GET"
   echo
}

# respond with the HTTP 400 (Bad Request) status code
code_400(){
   echo -e "HTTP/1.1 400 Bad Request\r"
   echo "WWW-Authenticate: Bearer realm='example', error='invalid_request', error_description='$1'"
   echo "Content-type: text/html; charset=UTF-8"
   echo
}

# in response to a protected resource request without authentication
# respond with the HTTP 401 (Unauthorized) status code
code_401_no_auth(){
   echo -e "HTTP/1.1 401 Unauthorized\r"
   echo "WWW-Authenticate: Bearer realm='example'"
   echo "Content-type: text/html; charset=UTF-8"
   echo
}

# respond with the HTTP 401 (Unauthorized) status code
code_401(){
   echo -e "HTTP/1.1 401 Unauthorized\r"
   echo "WWW-Authenticate: Bearer realm='example', error='invalid_token', error_description='$1'"
   echo "Content-type: text/html; charset=UTF-8"
   echo
}

# respond with the HTTP 403 (Forbidden) status code
code_403(){
   echo -e "HTTP/1.1 403 Forbidden\r"
   echo "WWW-Authenticate: Bearer realm='example', error='insufficient_scope', error_description='$1'"
   echo "Content-type: text/html; charset=UTF-8"
   echo
}

# status code 200 HTML default response
response_200(){
	cat <<- _EOF_
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
   <title>Protected Resource</title>
</head>
<body>
   <h3>Wellcome!</h3>
   <p>Hello $1, this is a protected resource.</p>
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

# add token hash to cache
add_to_cache(){
   echo "{\"hash\":\"${TOKEN_HASH}\",\"exp\":\"$exp\",\
\"name\":\"$name\"}" >> $TOKEN_CACHE
}

# remove token hash from cache
remove_from_cache(){
   perl -ni.bak -e "print unless /${TOKEN_HASH}/" ${TOKEN_CACHE}
}

# get typ value
get_typ(){
  typ=$(echo $header | python -c "import sys, json; print json.load(sys.stdin)['typ']")
  if [ $? -ne 0 ]; then
      code_400 "missing typ value"
      echo "400 (Bad Request)"
      exit 1
  fi
  if [ "$typ" != "$VALID_TYP" ]; then
      code_400 "unsuported typ"
      echo "400 (Bad Request)"
      exit 1
  fi
}

# get alg value
get_alg(){
  alg=$(echo $header | python -c "import sys, json; print json.load(sys.stdin)['alg']")
  if [ $? -ne 0 ]; then
      code_400 "missing alg value"
      echo "400 (Bad Request)"
      exit 1
  fi
  if [ "$alg" != "$VALID_ALGORITHM" ]; then
      code_400 "unsuported alg value"
      echo "400 (Bad Request)"
      exit 1
  fi
}

# get iss value
get_iss(){
  iss=$(echo $payload | python -c "import sys, json; print json.load(sys.stdin)['iss']")
  if [ $? -ne 0 ]; then
      code_400 "missing iss value"
      echo "400 (Bad Request)"
      exit 1
  fi
}

# get exp value
get_exp(){
  if [ "$1" == "cache" ]; then
     exp=$(echo $TOKEN_CACHE_VAL | python -c "import sys, json; print json.load(sys.stdin)['exp']")
  else
     exp=$(echo $payload | python -c "import sys, json; print json.load(sys.stdin)['exp']")
  fi
  if [ $? -eq 0 ]; then
      now=$(date +%s) # current time
      if [[ "$exp" -le "$now" ]]; then
	  code_401 "expired"
    	  echo "401 (Unauthorized)"
	  [ "$1" == "cache" ] && remove_from_cache
	  exit 1
      fi
  fi
}

# get dlt value
get_dlt(){
  dlt=$(echo $payload | python -c "import sys, json; print json.load(sys.stdin)['dlt']")
  if [ $? -ne 0 ]; then
      code_400 "missing dlt value"
      echo "400 (Bad Request)"
      exit 1
  fi 
  if [ "$dlt" != "$VALID_DLT" ]; then
      code_400 "${dlt} is not supported"
      echo "400 (Bad Request)"
      exit 1
  fi
}

# get dsn value
get_dsn(){
  dsn=$(echo $payload | python -c "import sys, json; print json.load(sys.stdin)['dsn']")
  if [ $? -ne 0 ]; then
      code_400 "missing dsn value"
      echo "400 (Bad Request)"
      exit 1
  fi
  if [ "$dsn" != "$VALID_DSN" ]; then
      code_400 "${dsn} is not supported"
      echo "400 (Bad Request)"
      exit 1
  fi
}

export PYTHONIOENCODING=utf8

# variables
CONF_DIR="conf"
RESPONSE_CONF="$CONF_DIR/jwt/consumer/response.conf"
DLT_CONF="$CONF_DIR/dlt/consumer/wallet.conf"
DSN_CONF="$CONF_DIR/dsn/consumer/dsn.conf"
typ=""
alg=""
iss=""
exp=""
dlt=""
name=""
address=""
uri=""

# verify exported variables
[ -z "${TMP_DIR}" ] && TMP_DIR="/tmp"
[ -z "${LOG_REQ}" ] && LOG_REQ="$TMP_DIR/requests.log"

# read configuration file(s)
[ -r "$RESPONSE_CONF" ] || error "$RESPONSE_CONF"
. $RESPONSE_CONF
[ -r "$DLT_CONF" ] || error "$DLT_CONF"
. $DLT_CONF
[ -r "$DSN_CONF" ] || error "$DSN_CONF"
. $DSN_CONF

# create token cache file
if [ ! -f $TOKEN_CACHE ]; then
    touch $TOKEN_CACHE
fi

# verify exported AUTH variable
if [ -z "${AUTH}" ]; then
    # get authentication request from log last line
    AUTH=$(cat $LOG_REQ | tail -2)
fi

# get header values
header1=$(echo $AUTH | awk '{print $1}' | xargs)
header2=$(echo $AUTH | awk '{print $2}' | xargs)

# verify header values
if [ "$header1" != "Authorization:" ] || [ "$header2" != "Bearer" ]; then
   code_401_no_auth
   echo "401 (Unauthorized)"
   exit 1
fi

# get access_token
access_token=$(echo $AUTH | awk '{print $3}' | xargs)

# create token hash
TOKEN_HASH=$(echo -n $access_token | sha1sum | awk '{print $1}' | xargs)

# is token hash in cache?
TOKEN_CACHE_VAL=$(grep -F "$TOKEN_HASH" $TOKEN_CACHE)
if [ $? -eq 0 ]; then # found
   get_exp cache
   name=$(echo $TOKEN_CACHE_VAL | python -c "import sys, json; print json.load(sys.stdin)['name']")
   code_200
   response_200 "$name"
   exit 0
fi

# stripping the JWT parts Header.Payload.Signature into an array
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

# get token values
get_typ
get_alg
get_iss
get_exp no_cache
get_dlt
get_dsn

# get the uri value from NMC
nshow=$(namecoin-cli -datadir=$NMC_DATA_DIR name_show "$iss")
out1=$(echo $nshow | python -c "import sys, json; print json.load(sys.stdin)['value']")
uri=$(echo $out1 | python -c "import sys, json; print json.load(sys.stdin)['uri']")

# validate authorization
if [ "$AUTHORIZATION" == "true" ]; then
   if [ ! -f $PROFILE_URI_CACHE ]; then
      curl --silent --output $PROFILE_URI_CACHE ${DSN_HTTP_GW}${PROFILE_URI}
   fi
   triples-knows.py $PROFILE_URI_CACHE | grep --quiet -w ${uri}
   if [ $? -ne 0 ]; then # not known
      code_403 "not known"
      response_403
      exit 1
   fi
fi

# get profile document from IPFS
tmpfile=$(mktemp /tmp/profile_XXXXXX)
curl --silent --output $tmpfile ${DSN_HTTP_GW}${uri}

# use SPARQL/triples to get maker name from profile
name=$(triples-person.py $tmpfile)

# use SPARQL/triple to get wallet address from profile
address=$(triples-accountName.py $tmpfile "${dlt}")

# remove temporary file
rm -f $tmpfile

# verify signature
verify=$(namecoin-cli -datadir=$NMC_DATA_DIR verifymessage $address $signature "$message")

if [ "$verify" == "true" ]; then
	code_200
	response_200 "$name"
	add_to_cache
	exit 0
  else
	code_403 "not authorized"
  	response_403
	exit 1
fi

exit 0
