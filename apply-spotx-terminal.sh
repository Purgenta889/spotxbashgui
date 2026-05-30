#!/usr/bin/bash

echo "Applying SpotX patch..."

bash -c "$(curl -sSL https://spotx-official.github.io/run.sh)"

echo
read -p "Press Enter to exit..."
