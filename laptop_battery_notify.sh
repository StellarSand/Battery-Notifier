#!/bin/sh

# Run this script as a cronjob every 5 minutes,
# to get notifications when battery is at or below 20% (discharging) and at or above 85% (charging) (for optimization).
# to get notifications when battery is fully charged or below 10% (critical level).
# in crontab -e:
# */5 * * * * /bin/sh /path/to/laptop_battery_notify.sh

# The following line is to make notify-send work when run in a crontab.
# https://unix.stackexchange.com/a/485719
export XDG_RUNTIME_DIR=/run/user/$(id -u)

LAPTOP_BATTERY_PATH=$(upower -e | grep battery)
LINE_POWER_PATH=$(upower -e | grep line_power)

CURRENT_LAPTOP_BATTERY_PERCENT=$(upower -i $LAPTOP_BATTERY_PATH | grep 'percentage:' | awk '{ print $2 }' | sed 's/%//')
CABLE_PLUGGED=$(upower -i $LINE_POWER_PATH | grep -A2 'line-power' | grep online | awk '{ print $2 }')

NOTIFY_ICON=$HOME/laptop_battery_notify/battery.svg

MAX_BATTERY_PERCENT=100
CHARGED_BATTERY_PERCENT=85
LOW_BATTERY_PERCENT=20
CRITICAL_BATTERY_PERCENT=10

NOTIF_SHOWN_FILE=/tmp/.laptop_battery_notify_val

# CHECK IF TMP FILE EXISTS FOR CHECKING NOTIFICATION VALUES
# IF NOT, CREATE A NEW FILE WITH APPROPRIATE VALUES
if [ ! -f $NOTIF_SHOWN_FILE ];
then
touch $NOTIF_SHOWN_FILE
echo -e "# DO NOT DELETE OR EDIT THIS FILE \n# VALUES ARE AUTO GENERATED & MANAGED BY laptop_battery_notify.sh \n\nMaxBat_NOTIF_SHOWN=0 \nChgdBat_NOTIF_SHOWN=0 \nLowBat_NOTIF_SHOWN=0 \nCritBat_NOTIF_SHOWN=0" > $NOTIF_SHOWN_FILE
fi

# CHECK IF CHARGING
if [ $CABLE_PLUGGED == 'yes' ];
then
	# CHECK IF NOTIFICATION HASN'T BEEN SHOWN AT 85%
	if [ $(sed '5q;d' $NOTIF_SHOWN_FILE) == 'ChgdBat_NOTIF_SHOWN=0' ];
	then
		# CHECK IF CURRENT BATTERY PERCENT IS GREATER THAN OR EQUAL TO 85%
   		if [ $CURRENT_LAPTOP_BATTERY_PERCENT -gt $CHARGED_BATTERY_PERCENT ];
    	then
       		/usr/bin/notify-send --urgency=critical --icon=$NOTIFY_ICON "Laptop Battery Optimization" "Battery more than 85%, unplug the charger."
       		sed -i '/Chgd/s/0/1/g' $NOTIF_SHOWN_FILE
       		sed -i '/Low/s/1/0/g' $NOTIF_SHOWN_FILE # RESET LowBat_NOTIF_SHOWN VALUE
       		sed -i '/Crit/s/1/0/g' $NOTIF_SHOWN_FILE # RESET CritBat_NOTIF_SHOWN VALUE
       	elif [ $CURRENT_LAPTOP_BATTERY_PERCENT == $CHARGED_BATTERY_PERCENT ];
       	then
       		/usr/bin/notify-send --urgency=critical --icon=$NOTIFY_ICON "Laptop Battery Optimization" "Battery reached 85%, unplug the charger."
       		sed -i '/Chgd/s/0/1/g' $NOTIF_SHOWN_FILE
       		sed -i '/Low/s/1/0/g' $NOTIF_SHOWN_FILE # RESET LowBat_NOTIF_SHOWN VALUE
       		sed -i '/Crit/s/1/0/g' $NOTIF_SHOWN_FILE # RESET CritBat_NOTIF_SHOWN VALUE
    	fi
    	
    # CHECK IF NOTIFICATION HASN'T BEEN SHOWN AT 100%
    elif [ $(sed '4q;d' $NOTIF_SHOWN_FILE) == 'MaxBat_NOTIF_SHOWN=0' ];
    then
    	# CHECK IF CURRENT BATTERY PERCENT IS EQUAL TO 100%
    	if [ $CURRENT_LAPTOP_BATTERY_PERCENT == $MAX_BATTERY_PERCENT ];
    	then
    		/usr/bin/notify-send --urgency=critical --icon=$NOTIFY_ICON "Battery Full" "Battery is fully charged, unplug the charger."
       		sed -i '/Max/s/0/1/g' $NOTIF_SHOWN_FILE
       		sed -i '/Low/s/1/0/g' $NOTIF_SHOWN_FILE # RESET LowBat_NOTIF_SHOWN VALUE
       		sed -i '/Crit/s/1/0/g' $NOTIF_SHOWN_FILE # RESET CritBat_NOTIF_SHOWN VALUE
       	fi
    fi

# IF NOT CHARGING
else	
	# CHECK IF NOTIFICATION HASN'T BEEN SHOWN AT 20%
	if [ $(sed '6q;d' $NOTIF_SHOWN_FILE) == 'LowBat_NOTIF_SHOWN=0' ];
	then
		# CHECK IF CURRENT BATTERY PERCENT IS LESS THAN OR EQUAL TO 20%
		if [ $CURRENT_LAPTOP_BATTERY_PERCENT -lt $LOW_BATTERY_PERCENT ];
		then
			/usr/bin/notify-send --urgency=critical --icon=$NOTIFY_ICON "Laptop Battery Optimization" "Battery is below 20%, plug in the charger."
        	sed -i '/Low/s/0/1/g' $NOTIF_SHOWN_FILE
        	sed -i '/Chgd/s/1/0/g' $NOTIF_SHOWN_FILE # RESET ChgdBat_NOTIF_SHOWN VALUE
        	sed -i '/Max/s/1/0/g' $NOTIF_SHOWN_FILE # RESET MaxBat_NOTIF_SHOWN VALUE
        elif [ $CURRENT_LAPTOP_BATTERY_PERCENT == $LOW_BATTERY_PERCENT ];
       	then
       		/usr/bin/notify-send --urgency=critical --icon=$NOTIFY_ICON "Laptop Battery Optimization" "Battery is at 20%, plug in the charger."
       		sed -i '/Low/s/0/1/g' $NOTIF_SHOWN_FILE
        	sed -i '/Chgd/s/1/0/g' $NOTIF_SHOWN_FILE # RESET ChgdBat_NOTIF_SHOWN VALUE
        	sed -i '/Max/s/1/0/g' $NOTIF_SHOWN_FILE # RESET MaxBat_NOTIF_SHOWN VALUE
        fi
	
	# CHECK IF NOTIFICATION HASN'T BEEN SHOWN AT 10%
	elif [ $(sed '7q;d' $NOTIF_SHOWN_FILE) == 'CritBat_NOTIF_SHOWN=0' ];
	then
		# CHECK IF CURRENT BATTERY PERCENT IS LESS THAN OR EQUAL TO 10%
		if [[ $CURRENT_LAPTOP_BATTERY_PERCENT -lt $CRITICAL_BATTERY_PERCENT || $CURRENT_LAPTOP_BATTERY_PERCENT == $CRITICAL_BATTERY_PERCENT ]];
		then
			/usr/bin/notify-send --urgency=critical --icon=$NOTIFY_ICON "Battery Level Critical" "Battery is at or below 10%, plug in the charger."
        	sed -i '/Crit/s/0/1/g' $NOTIF_SHOWN_FILE
        	sed -i '/Chgd/s/1/0/g' $NOTIF_SHOWN_FILE # RESET ChgdBat_NOTIF_SHOWN VALUE
        	sed -i '/Max/s/1/0/g' $NOTIF_SHOWN_FILE # RESET MaxBat_NOTIF_SHOWN VALUE
        fi
	fi

fi

exit 0
