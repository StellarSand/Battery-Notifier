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
                            Default = 10 seconds, 0 = Notify only once

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
        /usr/bin/notify-send --urgency=critical --icon=battery-charged "Battery Optimization" "Battery at $curr_bat_percent%, unplug the charger."
        playAudioFile
    elif [ "$curr_bat_percent" -le "$low_percent" ]
    then
        /usr/bin/notify-send --urgency=critical --icon=battery-low "Battery Optimization" "Battery at $curr_bat_percent%, plug in the charger."
        playAudioFile
    fi
}

# Check config directory
if [ ! -d "$config_dir" ]
then
	mkdir "$config_dir"
fi

# Check config file
if [ ! -f "$config_file" ]
then
cat << EOF >> "$config_file"
80
20
10

EOF
fi

chkPackage "upower"
chkPackage ""

bat_path=$(upower -e | grep -m1 "battery")
line_power_path=$(upower -e | grep "line_power")

curr_bat_percent=$(upower -i "$bat_path" | 
                   awk '/percentage:/ { gsub(/%/, "", $2); print $2 }') # search for "percentage:" 
                                                                        # replace % with "" & print 2nd field
is_charging=$(upower -i "$line_power_path" | 
              awk '/online/ { print $2 }') # search for "online" and print 2nd field

config_dir="$HOME/.config/battery-notify"
config_file="$config_dir/configs"
chgd_percent=$(head -1 "$config_file")
low_percent=$(sed -n 2p "$config_file")
repeat_times=$(sed -n 3p "$config_file")
audio_file=$(sed -n 4p "$config_file")

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
                chgd_percent="$2"
                sed -i "1i\$2" "$config_file" # write to 1st line of the file
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
                low_percent="$2"
                sed -i "2i\$2" "$config_file" # write to 2nd line of the file
                shift
            else
                echo "Please provide a valid percentage between 1-100"
                echo -e "Exiting script ...\n"
                exit 1
            fi
        ;;

        -r | --repeat)
            repeat_times="$2"
            sed -i "3i\$2" "$config_file" # write to 3rd line of the file
            shift
        ;;

        -s | --sound)
            if [ -f "$2" ]
            then
                if file "$2" | grep -q "Audio file"
                then
                    audio_file="$2"
                    sed -i "4i\$2" "config_file" # write to the 4th line of the file
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