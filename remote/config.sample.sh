#!/usr/bin/env sh

###
# Configuration example.
# Adjust according to your needs:


###
# geliremotealert

# Where does this mail come from?
export MAIL_FROM="Remote Messenger <noreply@example.com>"
# Where should the mail go to?
export MAIL_RCPT="mail@example.com"
# Define a subject here!
export MAIL_SUBJ="Remote Alert"


###
# geliremoteprovider

# Set this to the alert script if you want to get notified by mail.
# If left blank, no mail will be sent.
export ALERT_SCRIPT="$SELF_DIR/geliremotealert.sh"

# Specify base directory for keys
export DIR_KEYS="$SELF_DIR/keys"
# Specify base directory for passphrases
export DIR_PASS="$SELF_DIR/pass"
