#!/usr/bin/env bash

set -e

SELF_DIR="$(cd "$(dirname "$0")" && pwd || exit 2)"

# shellcheck source=remote/config.sample.sh
source "$SELF_DIR/config.sh"


# helper function to signal some error and exit
err() {
    (>&2 echo "error:" "$*")
    exit 1
}
# helper function to safely retrieve file contents
get() {
    [ ! -d "$1" ] && err "directory not found"
    [ -z "$2" ] && err "empty request"
    case $2 in
        *\.\.*) err "no double dots allowed" ;;
        */*) err "no slashes allowed" ;;
    esac
    [ ! -r "$1/$2" ] && err "file not found"
    cat "$1/$2"
}


# Parse the request. Using $* for local debugging
INPUT="$SSH_ORIGINAL_COMMAND"
[ -z "$INPUT" ] && INPUT="$*"
# Split the request into separate variables
IFS=' ' read -r COMMAND FILE <<< "$INPUT"


# Before doing anything else, send the alert mail (if configured)
[ -x "$ALERT_SCRIPT" ] && "${ALERT_SCRIPT}"

# parse known commands
case $COMMAND in
    keyfile)
        get "$DIR_KEYS" "$FILE"
        ;;
    passphrase)
        get "$DIR_PASS" "$FILE"
        ;;
    *)
        err "unknown command"
        ;;
esac

exit 0
