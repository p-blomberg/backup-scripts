#!/bin/bash

# Create strings
echo HOSTNAME=`hostname`
echo DAY_OF_WEEK=`date +%A`
echo KATALOGER=\" /home /root /var/www /etc \"
echo TARGET='please.change.this.hostname'

echo TMPDIR='/home/backupuser' # Must be absolute

