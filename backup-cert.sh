#!/bin/bash
#
# Backup letsencrypt /etc folder
#
# Description:
# Backup preserve perms (if we launch the command as root) and by default,
# tar preserves symlinks. The date part of the backup command will save the date
# and time we created the tar file.
#

SOURCE_DIR="/etc/letsencrypt"
DESTINATION_DIR="/tmp"
BACKUP_FILE_NAME="letsencrypt_backup_$(date +'%Y-%m-%d_%H%M').tar.gz"

if [ ! -d "$SOURCE_DIR" ]; then
   echo "Error: $SOURCE_DIR does not exist"
   exit 1
elif [ -z "$(ls -A $SOURCE_DIR)" ]; then
   echo "Error: empty $SOURCE_DIR"
   exit 1
else
   sudo tar zcvf $DESTINATION_DIR/$BACKUP_FILE_NAME $SOURCE_DIR
fi

echo
echo "Backup is concluded."
echo "You can check the content of backup file using command:"
echo "$ tar tvf $DESTINATION_DIR/$BACKUP_FILE_NAME"
echo "In order to recover $SOURCE_DIR dir use command:"
echo "$ tar zxvf $DESTINATION_DIR/$BACKUP_FILE_NAME -C /"
echo
