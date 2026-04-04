#!/bin/sh
# Discard all uploaded data and return 200 OK
cat > /dev/null
printf "Content-Type: text/plain\r\n\r\nOK"
