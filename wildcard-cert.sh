#!/bin/bash
#
# Install Let’s Encrypt Free SSL Wildcard Certificate
#
# Dependencies:
# certbot - https://certbot.eff.org/lets-encrypt/ubuntubionic-other
#

# chech arguments
if [[ "$#" -lt 1 || "$#" -gt 2 ]] ; then
  echo
  echo "Invalid number of arguments."
  echo "Usage: ./$(basename "$0") <domain_name> [--dry-run]"
  echo
  echo "Example:"
  echo
  echo "Save certificate(s)"
  echo "$ ./$(basename "$0") example.com"
  echo
  echo "Test without saving any certificate(s)"
  echo "$ ./$(basename "$0") example.com --dry-run"
  echo
  exit 1
fi

ACMEv2_SERVER="https://acme-v02.api.letsencrypt.org/directory"
REGISTER_UNSAFELY="--register-unsafely-without-email"
DRY_RUN=""

DOMAIN_NAME=$(echo $1 | grep -P '(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)')

if [ -z "$DOMAIN_NAME" ]; then
  echo "Error: invalid domain $1"
  exit 1
fi

if [ ! -z "$2" ]; then
   if [ "$2" != "--dry-run" ]; then
      echo "Error: invalid argument $2"
      exit 1
   else
      DRY_RUN="$2"
   fi
fi

sudo certbot certonly --manual -d *.${DOMAIN_NAME} -d ${DOMAIN_NAME} --agree-tos \
--no-bootstrap --manual-public-ip-logging-ok --preferred-challenges \
dns-01 --server ${ACMEv2_SERVER} ${REGISTER_UNSAFELY} ${DRY_RUN}
