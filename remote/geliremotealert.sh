#!/usr/bin/env sh

set -e

SELF_DIR="$(cd "$(dirname "$0")" && pwd || exit 2)"

# shellcheck source=remote/config.sample.sh
. "$SELF_DIR/config.sh"


TIME="$(date -Iseconds)"

{
    printf "From: %s\n" "$MAIL_FROM"
    printf "To: %s\n" "$MAIL_RCPT"
    printf "Subject: %s (%s)\n" "$MAIL_SUBJ" "$TIME"
    printf "Content-Type: %s\n" "text/plain"
    printf "\n"
    printf "Client      %s\n" "${SSH_CLIENT:-"-"}"
    printf "Connection  %s\n" "${SSH_CONNECTION:-"-"}"
    printf "Command     %s\n" "${SSH_ORIGINAL_COMMAND:-"-"}"
    printf "TTY         %s\n" "${SSH_TTY:-"-"}"
    printf "Args        %s\n" "${*:-"-"}"
    printf "Time        %s\n" "$TIME"
    printf "\n"
} | sendmail -t

exit 0
