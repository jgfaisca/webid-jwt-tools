#!/bin/bash
#
# Print TLS certificate fingerprint
#

# chech arguments
if [ $# -ne 1 ]; then
  echo
  echo "Invalid number of arguments."
  echo "Usage: ./$(basename "$0") <host:port>"
  echo
  echo "Example:"
  echo "./$(basename "$0") gnu.org:443"
  echo
  exit 1
fi


HOST_PORT="$1"

FPRINT_0=$(echo | openssl s_client -connect $HOST_PORT |& openssl x509 -fingerprint -noout | cut -f2 -d'=')
FPRINT_0="${FPRINT_0//:}"
echo $FPRINT_0

exit 0
