#!/bin/bash

# Check for lock file
if [ -e /home/backupuser/backup_mysql.lock ]; then
	echo "***** Lock file /home/backupuser/backup_mysql.lock exists, bailing out." >&2
	exit 1
fi

# Create lock file
touch /home/backupuser/backup_mysql.lock
if [ $? -eq 0 ]; then
        echo "***** Lock file created"
else
        echo "***** Unable to create lock file" >&2
        exit 2
fi

# Run settings file
eval $(/home/backupuser/backup_mysql_settings.sh)

# Delete target directory
ssh $TARGET rm -fr mysql/$VECKODAG.$TIMME
if [ $? -eq 0 ]; then
	echo "***** Target directory deleted successfully."
else
	echo "***** Delete of target directory failed! Exiting." >&2
	rm /home/backupuser/backup_mysql.lock
	exit 2
fi

# Create target directory
ssh $TARGET mkdir -p mysql/$VECKODAG.$TIMME
if [ $? -eq 0 ]; then
	echo "***** Target directory created successfully."
else
	echo "***** Failed to create target directory! Exiting." >&2
	rm /home/backupuser/backup_mysql.lock
	exit 3
fi

# Create local dump file
FILENAME="/home/backupuser/mysqldump.$HOSTNAME.$VECKODAG.$TIMME.sql"
mysqldump -u $MYSQL_USER --password=$MYSQL_PASS --all-databases > $FILENAME
if [ $? -eq 0 ]; then
	echo "***** Dump file created successfully."
else
	echo "***** Failed to create dump file! Exiting." >&2
	rm /home/backupuser/backup_mysql.lock
	exit 4
fi

# Transfer the dump file
done=0
until [  $done -eq 1 ]; do
	rsync -rav --timeout=30 $FILENAME $TARGET:mysql/$VECKODAG.$TIMME/
	if [ $? -eq 0 ]; then
		echo "***** Backup completed!"
		done=1
	else
		echo "***** Backup failed, sleeping 15 seconds before retrying." >&2
		sleep 15
	fi
done

# Delete local dump file
rm $FILENAME
if [ $? -eq 0 ]; then
	echo "***** Dump file deleted successfully."
else
	echo "***** Failed to delete dump file." >&2
	exit 5
fi

# Delete lock file
rm /home/backupuser/backup_mysql.lock
if [ $? -eq 0 ]; then
	echo "***** Lock file deleted successfully."
else
	echo "***** Failed to delete lock file." >&2
	exit 6
fi

# Clean exit
exit 0
