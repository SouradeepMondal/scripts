#!/bin/bash

# Check if the drivetemp module is loaded
if ! lsmod | grep -q drivetemp; then
    echo "Loading drivetemp module..."
    sudo modprobe drivetemp
    if [ $? -ne 0 ]; then
        echo "Failed to load drivetemp module. Please check your permissions."
        exit 1
    fi
fi

# Get and display the temperature values
grep -l "drivetemp" /sys/class/hwmon/hwmon*/name | while read -r f; do
    if [[ -r "${f%/*}/device/model" && -r "${f%/*}/temp1_input" ]]; then
        model=$(cat "${f%/*}/device/model")
        temperature=$(( $(cat "${f%/*}/temp1_input") / 1000 ))
        echo "$model $temperature°C"
    else
        echo "Permission denied to read device files. Try running with sudo."
    fi
done

