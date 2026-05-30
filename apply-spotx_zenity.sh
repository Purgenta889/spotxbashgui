#!/usr/bin/env bash

# -------------------------
# Confirm install
# -------------------------
zenity --question \
  --title="SpotX Bash" \
  --text="Patch Spotify with SpotX?\nAdministrator permissions are required." \
  --ok-label="Patch" \
  --cancel-label="Cancel"

[ $? -ne 0 ] && exit 0

# -------------------------
# Temp files
# -------------------------
LOGFILE=$(mktemp)
SPOTX_SCRIPT="/tmp/spotx.sh"

# -------------------------
# GUI password prompt
# -------------------------
PASSWORD=$(zenity --password \
  --title="Authentication Required" \
  --text="Enter your administrator password:")

[ -z "$PASSWORD" ] && exit 1

# -------------------------
# Download SpotX
# -------------------------
(
    echo "20"
    echo "# Downloading SpotX..."

    curl -sSL https://spotx-official.github.io/run.sh -o "$SPOTX_SCRIPT"
    chmod +x "$SPOTX_SCRIPT"

    echo "50"
    echo "# Patching Spotify..."

    echo "$PASSWORD" | sudo -S bash "$SPOTX_SCRIPT" 2>&1 | tee "$LOGFILE"

    echo "100"
    echo "# Done"

) | zenity --progress \
    --title="SpotX Bash" \
    --text="Starting..." \
    --percentage=0 \
    --auto-close \
    --no-cancel

EXIT_CODE=${PIPESTATUS[0]}

unset PASSWORD

# -------------------------
# Log viewer
# -------------------------
show_log() {
    zenity --text-info \
      --title="SpotX Log Output" \
      --filename="$LOGFILE" \
      --width=700 \
      --height=500 \
      --auto-scroll
}

# -------------------------
# Failure handling
# -------------------------
if [ "$EXIT_CODE" -ne 0 ]; then

    zenity --question \
      --title="SpotX Failed" \
      --text="SpotX failed to patch Spotify." \
      --ok-label="Show Log" \
      --cancel-label="Close"

    [ $? -eq 0 ] && show_log

    rm -f "$LOGFILE" "$SPOTX_SCRIPT"
    exit 1
fi

# -------------------------
# Success / already patched handling
# -------------------------
if grep -qi "already been installed" "$LOGFILE"; then
    zenity --question \
      --title="SpotX Bash" \
      --text="Spotify is already patched." \
      --ok-label="Show Log" \
      --cancel-label="Close"

    [ $? -eq 0 ] && show_log
else
    zenity --question \
      --title="SpotX Bash" \
      --text="Spotify successfully patched with SpotX." \
      --ok-label="Show Log" \
      --cancel-label="Close"

    [ $? -eq 0 ] && show_log
fi

rm -f "$LOGFILE" "$SPOTX_SCRIPT"
