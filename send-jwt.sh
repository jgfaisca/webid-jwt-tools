
#!/bin/bash
#
# Send JWT on the HTTP Authorization header 
#

JWT="xxxxxxxxxxxxx3"
HOST="http://localhost"
PORT=8888

curl -H "Authorization: Token ${JWT}" ${HOST}:${PORT} || printf '%s\n' $?
