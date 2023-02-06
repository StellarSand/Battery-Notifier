#!/usr/bin/env bash

# Copyright (c) 2023 the-weird-aquarian

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/${UID}/bus}"

chkPackage() {
if ! (command -v "$1" > /dev/null)
then
  echo -e "\n$1 package does not exist. Please install it first and try again."
  echo -e "Exiting script ...\n"
  exit 1
fi
}

# Show usage
usage() {

cat << EOF

Usage:
battery-notify -c <battery charged percent> -l <battery low percent>

Description:
Monitor and notify when battery reaches optimization level

Available options:
 -h,    --help              Show this help message
 -c,    --charged           Set battery charged percent
 -l,    --low               Set battery low percent
 -s,    --sound             Set custom notification sound
 -r,    --repeat            Repeat notification at set interval (in seconds)
                            Default = 60 seconds, 0 = Notify only once

Examples:
battery-notify -c 60 -l 30
battery-notify -s /home/user/Music/audio.wav

EOF

}

playAudioFile() {
    if [ -n "$audio_file" ]
    then
        if chkPackage "aplay"
        then
            aplay "$audio_file"
        elif chkPackage "paplay"
        then
            paplay "$audio_file"
        fi
    fi
}

notify(){
    if [ "$is_charging" == "yes" ] && [  "$curr_bat_percent" -ge "$chgd_percent"  ]
    then
        /usr/bin/notify-send --urgency=critical --icon=battery-charged "Battery Optimization" "Battery at ${curr_bat_percent}%, unplug the charger."
        playAudioFile
    elif [ "$curr_bat_percent" -le "$low_percent" ]
    then
        /usr/bin/notify-send --urgency=critical --icon=battery-low "Battery Optimization" "Battery at ${curr_bat_percent}%, plug in the charger."
        playAudioFile
    fi
}

chkPackage "upower"

bat_path=$(upower -e | grep -m1 "battery")
line_power_path=$(upower -e | grep "line_power")

curr_bat_percent=$(upower -i "$bat_path" | 
                   awk '/percentage:/ { gsub(/%/, "", $2); print $2 }') # search for "percentage:" 
                                                                        # replace % with "" & print 2nd field
is_charging=$(upower -i "$line_power_path" | 
              awk '/online/ { print $2 }') # search for "online" and print 2nd field

config_dir="$HOME/.config/battery-notify"
config_file="$config_dir/configs"

# Check config directory
if [ ! -d "$config_dir" ]
then
	mkdir "$config_dir"
fi

# Check config file
if [ ! -f "$config_file" ]
then
cat << EOF >> "$config_file"
chgd_percent=80
low_percent=20
repeat_times=60
audio_file=
EOF
fi

chgd_percent=$(while read -r
                do
                    awk 'match($0, /chgd_percent=([0-9]*)/, a){print a[1]}'
                done < "$config_file")

low_percent=$(while read -r
                do
                    awk 'match($0, /low_percent=([0-9]*)/, a){print a[1]}'
                done < "$config_file")

repeat_times=$(while read -r
                do
                    awk 'match($0, /repeat_times=([0-9]*)/, a){print a[1]}'
                done < "$config_file")

audio_file=$(while read -r
                do
                    awk 'match($0, /file=([A-z0-9./]*)/, a){print a[1]}'
                done < "$config_file")

# Process options
while [ $# -gt 0 ]
do
    case "$1" in

        -h | --help)
            usage
            exit 0
        ;;

        -c | --charged)
            if [ "$2" -le 100 ] && [ "$2" -ge 1 ]
            then
                sed -i "s/chgd_percent=${chgd_percent}/chgd_percent=${2}/g" "$config_file"
                chgd_percent="$2"
                shift
            else
                echo "Please provide a valid percentage between 1-100"
                echo -e "Exiting script ...\n"
                exit 1
            fi
        ;;

        -l | --low)
            if [ "$2" -le 100 ] && [ "$2" -ge 1 ]
            then
                sed -i "s/low_percent=${low_percent}/low_percent=${2}/g" "$config_file"
                low_percent="$2"
                shift
            else
                echo "Please provide a valid percentage between 1-100"
                echo -e "Exiting script ...\n"
                exit 1
            fi
        ;;

        -r | --repeat)
            sed -i "s/repeat_times=${repeat_times}/repeat_times=${2}/g" "$config_file"
            repeat_times="$2"
            shift
        ;;

        -s | --sound)
            if [ -f "$2" ]
            then
                if file "$2" | grep -q "Audio file"
                then
                    sed -i "s/audio_file=${audio_file}/audio_file=${2}/g" "$config_file"
                    audio_file="$2"
                    shift
                else
                    echo "$2 is not an audio file"
                    echo -e "Exiting script ...\n"
                    exit 1
                fi
            else
                echo "$2 does not exist"
                echo -e "Exiting script ...\n"
                exit 1
            fi
        ;;
    
    esac
    exit 0

done

if [ -z "$repeat_times" ]
then
    notify
else
    while true
    do
        notify
        sleep "$repeat_times"
    done
fi

exit 0
