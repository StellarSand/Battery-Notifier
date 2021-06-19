#!bin/sh

echo ""
echo "Battery Notifier"
echo ""

INSTALL_DIR=$HOME/laptop_battery_notify
CURRENT_DIR=$HOME/Battery-Notifier
SCRIPT=laptop_battery_notify.sh
BATT_DARK=$CURRENT_DIR/images/battery_dark.svg
BATT_LIGHT=$CURRENT_DIR/images/battery_light.svg
BATT_ICON=battery.svg

if [ ! -d $INSTALL_DIR ];
then
	mkdir $INSTALL_DIR
	echo "Installing in" $INSTALL_DIR  "..."
	echo ""
	cp $CURRENT_DIR/$SCRIPT $INSTALL_DIR/$SCRIPT
	echo "Fixing permissions ..."
	echo ""
	chmod +x $INSTALL_DIR/$SCRIPT
	echo "Please select if you're using a dark or light theme"
	echo "1. Dark"
	echo "2. Light"
	echo ""
	read -p '[Enter 1 or 2]: ' theme

	if [ $theme == '1' ];
	then
		cp $CURRENT_DIR/$BATT_DARK $INSTALL_DIR/$BATT_ICON
	else
		cp $CURRENT_DIR/$BATT_LIGHT $INSTALL_DIR/$BATT_ICON
	fi
	
	echo ""
	echo "Setting up cronjob ..."
	(crontab -l ; echo "*/5 * * * * /bin/sh" $INSTALL_DIR/$SCRIPT) | crontab -
	echo ""
	echo "Done"
	echo ""
	
else
	echo "Directory" $INSTALL_DIR "already exists."
	echo ""
fi

exit 0

