#!/bin/bash

set -e

app=$(basename $(pwd))

echo "Making app UF2..."
python ../../zephyr/scripts/build/uf2conv.py build/$app/zephyr/zephyr.signed.bin --convert --base 0x10010000 --family RP2040 --output build/app.uf2

echo "Flashing MCUBoot UF2..."
picotool load build/mcuboot/zephyr/zephyr.uf2

echo "Flashing app UF2..."
picotool load build/app.uf2

echo "Rebooting..."
picotool reboot

echo "Done"
