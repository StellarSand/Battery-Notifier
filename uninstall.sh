#!bin/sh

echo ""
echo "Battery Notifier"
echo ""

INSTALL_DIR=$HOME/laptop_battery_notify
SCRIPT=laptop_battery_notify_test.sh

if [ -d $INSTALL_DIR ];
then
	echo "Uninstalling ..."
	rm -rf $INSTALL_DIR
	echo ""
	echo "Removing cronjob ..."
	crontab -l | grep -v "* * * * * /bin/sh $INSTALL_DIR/$SCRIPT" | crontab
	echo ""
	echo "Done"
fi
	
exit 0

