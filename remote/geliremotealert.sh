#!/usr/bin/env bash

set -e

SELF_DIR="$(cd "$(dirname "$0")" && pwd || exit 2)"

# shellcheck source=remote/config.sample.sh
source "$SELF_DIR/config.sh"


TIME="$(date -Iseconds)"

{
    printf "From: %s\n" "$MAIL_FROM"
    printf "To: %s\n" "$MAIL_RCPT"
    printf "Subject: %s (%s)\n" "$MAIL_SUBJ" "$TIME"
    printf "Content-Type: %s\n" "text/plain"
    printf "\n"
    printf "\n"
    printf "Client\n"
    printf "\t%s\n" "$SSH_CLIENT"
    printf "\n"
    printf "Connection\n"
    printf "\t%s\n" "$SSH_CONNECTION"
    printf "\n"
    printf "Command\n"
    printf "\t%s\n" "$SSH_ORIGINAL_COMMAND"
    printf "\n"
    printf "TTY\n"
    printf "\t%s\n" "$SSH_TTY"
    printf "\n"
    printf "Extra\n"
    printf "\t%s\n" "$*"
    printf "\n"
    printf "Time\n"
    printf "\t%s\n" "$TIME"
    printf "\n"
} | sendmail -t

exit 0
