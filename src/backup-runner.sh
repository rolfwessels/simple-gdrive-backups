#!/bin/sh
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color


# Configuration variables
BACKUP_SOURCE_FOLDER="${BACKUP_SOURCE_FOLDER:-/data/source}"
BACKUP_FOLDER=${BACKUP_FOLDER:-/data/backup}
ZIP_NAME=${ZIP_NAME:-backup}
BACKUP_REMOTE_FOLDER=${BACKUP_REMOTE_FOLDER:-/data/backup/$ZIP_NAME}
MAX_BACKUPS=${MAX_BACKUPS:-7}

# Create the backup directory if it doesn't exist
mkdir -p "$BACKUP_FOLDER"
mkdir -p "$BACKUP_SOURCE_FOLDER"

# Generate the zip file name based on the configured format
ZIP_FILE_NAME=$(date +"$ZIP_NAME.%Y-%m-%d").zip


echo -e "Zip ${GREEN}$BACKUP_SOURCE_FOLDER ${NC} folder to ${RED}"$BACKUP_FOLDER/$ZIP_FILE_NAME ${NC}""
cd $BACKUP_SOURCE_FOLDER
zip -rq "$BACKUP_FOLDER/$ZIP_FILE_NAME" .
echo File zipped with size $(du -sh "$BACKUP_FOLDER/$ZIP_FILE_NAME" )
echo Remove files older than $MAX_BACKUPS days

find "$BACKUP_FOLDER/$ZIP_NAME"* -mtime +$MAX_BACKUPS
find "$BACKUP_FOLDER/$ZIP_NAME"* -mtime +$MAX_BACKUPS -exec rm {} \;

if [ -n "$RCLONE_REMOTE_NAME" ]; then
  echo "Remote name found: $RCLONE_REMOTE_NAME $BACKUP_REMOTE_FOLDER"
  rclone sync "$BACKUP_FOLDER" "$RCLONE_REMOTE_NAME:/data/backup/"
  echo "Backup synced to remote: $RCLONE_REMOTE_NAME"
fi

echo Done

