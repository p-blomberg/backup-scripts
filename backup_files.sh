#!/bin/bash

# Check for lock file
if [ -e /root/backup_files.lock ]; then
	echo "***** Lock file /root/backup_files.lock exists, bailing out." >&2
	exit 1
fi

# Create lock file
touch /root/backup_files.lock

# Run settings file
eval $(/root/backup_files_settings.sh)

# Delete target directory
ssh -l $HOSTNAME -i .ssh/root@$HOSTNAME.key $TARGET rm -fr files/$VECKODAG
if [ $? -eq 0 ]; then
	echo "***** Target directory deleted successfully."
	done=1
else
	echo "***** Delete of target directory failed, bailing out." >&2
	exit 2
fi

# Do the backup
done=0
until [  $done -eq 1 ]; do
	rsync -rav --delete --exclude-from=/root/backup_files.exclude --link-dest=../LATEST/ --timeout=30 -e "ssh -l $HOSTNAME -i /root/.ssh/root@$HOSTNAME.key" $KATALOGER $TARGET:files/$VECKODAG/
	if [ $? -eq 0 ]; then
		echo "***** Backup completed!"
		done=1
	else
		echo "***** Backup failed, sleeping 15 seconds before retrying." >&2
		sleep 15
	fi
done

# Delete the LATEST link
ssh -l $HOSTNAME -i .ssh/root@$HOSTNAME.key $TARGET rm -fr files/LATEST
if [ $? -eq 0 ]; then
	echo "***** Delete of the link LATEST completed successfully."
	done=1
else
	echo "***** Delete of the link LATEST failed, bailing out."
	exit 2
fi

# Update link to latest backup
ssh -l $HOSTNAME -i .ssh/root@$HOSTNAME.key $TARGET cp -al files/$VECKODAG files/LATEST
if [ $? -eq 0 ]; then
	echo "***** cp -al files/$VECKODAG files/LATEST completed successfully."
	done=1
else
	echo "***** cp -al files/$VECKODAG files/LATEST failed, bailing out." >&2
	exit 2
fi

# Delete lock file
rm /root/backup_files.lock
if [ $? -eq 0 ]; then
	echo "***** Lock file deleted successfully."
else
	echo "***** Failed to delete lock file." >&2
	exit 6
fi

# Clean exit
exit 0
