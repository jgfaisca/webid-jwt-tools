#!/bin/bash
#
# Create docker container
#

if [ -z "$1" ]; then
 echo
 echo "Usage: ./$(basename $0) <container_name>"
 echo
 exit 1
fi

# Docker image
IMG="zekaf/consume-jwt"
TAG="latest"

# Docker network
NET_NAME="isolated_nw2"
JWTS_IP="10.18.0.8"

# Docker jwt-server container
JWTS_CT="$1"

docker run -d \
	--net $NET_NAME --ip $JWTS_IP \
	--name $JWTS_CT \
	--restart=always \
	-p 8888:8888 \
	$IMG:$TAG




