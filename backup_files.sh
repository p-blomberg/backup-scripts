#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Run settings file
eval $($DIR/backup_files_settings.sh)

# Check for lock file
if [ -e $TMPDIR/backup_files.lock ]; then
	echo "***** Lock file $TMPDIR/backup_files.lock exists, bailing out." >&2
	exit 1
fi

# Create lock file
touch $TMPDIR/backup_files.lock

# Delete target directory
ssh $TARGET rm -fr files/$DAY_OF_WEEK
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
	rsync -rav --delete --exclude-from=$DIR/backup_files.exclude --link-dest=../LATEST/ --timeout=30 $BACKUP_THIS $TARGET:files/$DAY_OF_WEEK/
	if [ $? -eq 0 ]; then
		echo "***** Backup completed!"
		done=1
	else
		echo "***** Backup failed, sleeping 15 seconds before retrying." >&2
		sleep 15
	fi
done

# Delete the LATEST link
ssh $TARGET rm -fr files/LATEST
if [ $? -eq 0 ]; then
	echo "***** Delete of the link LATEST completed successfully."
	done=1
else
	echo "***** Delete of the link LATEST failed, bailing out."
	exit 2
fi

# Update link to latest backup
ssh $TARGET cp -al files/$DAY_OF_WEEK files/LATEST
if [ $? -eq 0 ]; then
	echo "***** cp -al files/$DAY_OF_WEEK files/LATEST completed successfully."
	done=1
else
	echo "***** cp -al files/$DAY_OF_WEEK files/LATEST failed, bailing out." >&2
	exit 2
fi

# Delete lock file
rm $TMPDIR/backup_files.lock
if [ $? -eq 0 ]; then
	echo "***** Lock file deleted successfully."
else
	echo "***** Failed to delete lock file." >&2
	exit 6
fi

# Clean exit
exit 0
