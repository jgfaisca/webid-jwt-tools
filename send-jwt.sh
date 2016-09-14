
#!/bin/bash
#
# Send JWT on the HTTP Authorization header 
#

JWT=$(cat access_token)
HOST="http://192.168.15.54"
PORT=8888

curl -H "Authorization: Token ${JWT}" ${HOST}:${PORT} || printf '%s\n' $?
