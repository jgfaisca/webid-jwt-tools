#!/bin/bash
#
# Decode JWT
# Using the Linux Bash base64 command and the jq utility
# (JSON processor for shell) https://stedolan.github.io/jq/
#

function error(){
  code=$1
  [ $code -eq 1 ] && echo "File not found."
  [ $code -eq 2 ] && echo "Wrong number of JWT elements ($elements)"
  exit 1
}

# Token files
file1="unencoded_token"
file2="access_token"

# -- Encode --

# Read the unencoded token
[ -f $file1 ] && unencoded_token=$(cat $file1) || error 1

# Stripping the JWT parts Header.Payload.Signature into an array
declare -a ujwt
#IFS='. ' read -r -a ujwt <<< "$unencoded_token"

ujwt[0]=$(echo $unencoded_token | awk -F '[/.]' '{print $1}')
ujwt[1]=$(echo $unencoded_token | awk -F '[/.]' '{print $2}')
ujwt[2]=$(echo $unencoded_token | awk -F '[/.]' '{print $3}')

elements="${#ujwt[@]}"
[ $elements -ne 3 ] && error 2

# Print the ujwt array
for index in "${!ujwt[@]}"; do
    echo "$index ${ujwt[index]}"
done

rm -f $file2
touch $file2

# Encode
for index in 0 1 ;do
    enc=$(echo "${ujwt[index]}" | base64)
    printf "$enc." >> $file2
done

enc=$(echo "${ujwt[2]}")
printf "$enc" >> $file2

# -- Decode ---

# Read the access token
[ -f $file2 ] && access_token=$(cat $file2) || error 1

# Stripping the JWT parts Header.Payload.Signature into an array
declare -a jwt
IFS='. ' read -r -a jwt <<< "$access_token"

elements="${#jwt[@]}"
[ $elements -ne 3 ] && error 2

# Print the jwt array
for index in "${!jwt[@]}"
do
    echo "$index ${jwt[index]}"
done

# verify jq utility 
jq --version >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "jq is not being recognized as a command; please install ";
fi

# Header decoding
echo "${jwt[0]}" | base64 -d | jq '.'

# Payload decoding
echo "${jwt[1]}" | base64 -d | jq '.'

