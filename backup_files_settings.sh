#!/bin/bash

# Create strings
echo HOSTNAME=`hostname`
DAY_OF_WEEK=`date +%A`
HOUR=`date +%H`

# Remember, REMOTE_PATH adjusts how long backups will be kept before overwritten. 
# $DAY_OF_WEEK.$HOUR means it will be kept until the script is run at the same day of the week on the same hour.
# If you only run the script daily, uncomment this line instead:
# echo REMOTE_PATH=files/$DAY_OF_WEEK
echo REMOTE_PATH=files/$DAY_OF_WEEK.$HOUR
echo REMOTE_LINK=files/LATEST
echo BACKUP_THIS=\" /home /root /var/www /etc \"
echo TARGET='please.change.this.hostname'

echo TMPDIR='/home/backupuser' # Must be absolute

