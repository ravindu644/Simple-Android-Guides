#!/bin/bash

wdir=$(pwd)
if [ ! -d "$wdir/nethunter" ]; then
    mkdir nethunter
    cd nethunter || exit
    wget "https://raw.githubusercontent.com/ravindu644/Simple-Android-Guides/nethunter/nethunter/Kconfig"
    cd "$wdir" || exit
fi

if grep -q 'source "nethunter/Kconfig"' "$wdir/arch/arm64/Kconfig"; then
    echo "Line already exists in arch/arm64/Kconfig. Skipping..."
else
    echo 'source "nethunter/Kconfig"' >> "$wdir/arch/arm64/Kconfig"
    echo "Line added to arch/arm64/Kconfig."
fi
