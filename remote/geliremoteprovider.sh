#!/usr/bin/env bash

set -e

###
# Adjust according to your needs


# Where do we live?
SELF_DIR="$(cd "$(dirname "$0")" && pwd || exit 2)"

# Set this to the alert script if you want to get notified by mail.
# If left blank, no mail will be sent.
ALERT_SCRIPT="$SELF_DIR/geliremotealert.sh"

# Specify base directory for keys
DIR_KEYS="$SELF_DIR/keys"
# Specify base directory for passphrases
DIR_PASS="$SELF_DIR/pass"


# Do not edit below this line
###

# Parse the request. Using $* for local debugging
INPUT="$SSH_ORIGINAL_COMMAND"
[ -z "$INPUT" ] && INPUT="$*"
# Split the request into separate variables
IFS=' ' read -r COMMAND FILE <<< "$INPUT"


# Before doing anything else, send the alert mail (if configured)
[ -x "$ALERT_SCRIPT" ] && "${ALERT_SCRIPT}"


# helper function to signal some error and exit
err() {
	(>&2 echo "error")
	[ -n "$*" ] && (>&2 echo "$*")
	exit 1
}
# helper function to safely retrieve file contents
get() {
	[ ! -d "$1" ] && err "directory not found"
	[ ! -n "$2" ] && err "no file requested"
	[ ! -r "$1/$2" ] && err "file not found"
	cat "$1/$2"
}

# parse known commands
case $COMMAND in
	keyfile)
		get "$DIR_KEYS" "$FILE"
		;;
	passphrase)
		get "$DIR_PASS" "$FILE"
		;;
	*)
		err
		;;
esac

exit 0
