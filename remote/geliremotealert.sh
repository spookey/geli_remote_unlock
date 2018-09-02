#!/usr/bin/env bash

set -e

###
# Adjust according to your needs


# Where does this mail come from?
FROM="Remote Messenger <noreply@example.com>"
# Where should the mail go to?
RCPT="mail@example.com"
# Define a subject here!
SUBJ="Remote Alert"


# Do not edit below this line
###

TIME="$(date "+%Y-%m-%d %H-%M-%S")"

{
    echo "From: $FROM"
    echo "To: $RCPT"
    echo "Subject: $SUBJ ($TIME)"
    echo "Content-Type: text/plain"
    echo
    echo
    echo "Client"
    echo -e "\\t" "$SSH_CLIENT"
    echo
    echo "Connection"
    echo -e "\\t" "$SSH_CONNECTION"
    echo
    echo "Command"
    echo -e "\\t" "$SSH_ORIGINAL_COMMAND"
    echo
    echo "TTY"
    echo -e "\\t" "$SSH_TTY"
    echo
    echo "Time"
    echo -e "\\t" "$TIME"
    echo
} | sendmail -t

exit 0
