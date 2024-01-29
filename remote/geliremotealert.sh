#!/usr/bin/env bash

set -e

SELF_DIR="$(cd "$(dirname "$0")" && pwd || exit 2)"

# shellcheck source=remote/config.sample.sh
source "$SELF_DIR/config.sh"


TIME="$(date -Iseconds)"

{
    echo "From: $MAIL_FROM"
    echo "To: $MAIL_RCPT"
    echo "Subject: $MAIL_SUBJ ($TIME)"
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
