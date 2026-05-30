#!/usr/bin/env bash

# -------------------------
# Confirm install
# -------------------------
yad --question \
  --title="SpotX Bash" \
  --text="Patch Spotify with SpotX? Administrator permissions are required." \
  --button="Patch":0 \
  --button="Cancel":1 \
  --width=380

[ $? -ne 0 ] && exit 0

# -------------------------
# Ask for password
# -------------------------
PASSWORD=$(yad --entry \
  --title="Authentication Required" \
  --text="Enter your administrator password:" \
  --hide-text \
  --width=360)

[ -z "$PASSWORD" ] && exit 1

# -------------------------
# Temp log
# -------------------------
LOGFILE=$(mktemp)

# -------------------------
# Status window
# -------------------------
yad --info \
  --title="SpotX Patcher" \
  --text="Patching Spotify..." \
  --no-buttons \
  --timeout=999999 &
UI_PID=$!

# -------------------------
# Run SpotX
# -------------------------
echo "$PASSWORD" | sudo -S bash -c \
  "$(curl -sSL https://spotx-official.github.io/run.sh)" \
  2>&1 | tee "$LOGFILE"

EXIT_CODE=${PIPESTATUS[0]}

unset PASSWORD

# -------------------------
# Close status window
# -------------------------
kill "$UI_PID" 2>/dev/null

# -------------------------
# Log viewer
# -------------------------
show_details() {
    yad --text-info \
      --title="SpotX Log" \
      --filename="$LOGFILE" \
      --width=700 \
      --height=500 \
      --auto-scroll \
      --button="Close":0
}

# -------------------------
# Better detection
# -------------------------
ALREADY_PATCHED=false

if grep -Eqi \
  "already been installed|already installed|already patched|is already installed|already exists" \
  "$LOGFILE"; then
    ALREADY_PATCHED=true
fi

# -------------------------
# Failure handling
# -------------------------
if [ "$EXIT_CODE" -ne 0 ]; then

    if $ALREADY_PATCHED; then
        yad --question \
          --title="SpotX Bash" \
          --text="Spotify is already patched." \
          --button="Show Log":0 \
          --button="Close":1 \
          --width=380

        [ $? -eq 0 ] && show_details
    else
        yad --question \
          --title="SpotX Bash" \
          --text="SpotX failed to patch Spotify." \
          --button="Show Log":0 \
          --button="Close":1 \
          --width=420

        [ $? -eq 0 ] && show_details
    fi

    rm -f "$LOGFILE"
    exit 1
fi

# -------------------------
# Success handling
# -------------------------
if $ALREADY_PATCHED; then
    yad --question \
      --title="SpotX Bash" \
      --text="Spotify is already patched." \
      --button="Show Log":0 \
      --button="Close":1 \
      --width=380

    [ $? -eq 0 ] && show_details
else
    yad --question \
      --title="SpotX Bash" \
      --text="Spotify successfully patched with SpotX." \
      --button="Show Log":0 \
      --button="Close":1 \
      --width=380

    [ $? -eq 0 ] && show_details
fi

rm -f "$LOGFILE"
