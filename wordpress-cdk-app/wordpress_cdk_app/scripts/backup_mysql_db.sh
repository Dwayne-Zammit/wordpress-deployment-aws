#!/bin/bash

# Variables
DB_NAME="wordpress"
DB_USER="wordpressuser"
DB_PASSWORD="wordpresspassword"
S3_BUCKET=aws cloudformation describe-stacks --stack-name WordpressCdkAppStack --query "Stacks[0].Outputs[?OutputKey=='S3BucketName'].OutputValue" --output text
BACKUP_PATH="/tmp/mysql_backup"  # Temporary folder for the backup
DATE=$(date +"%Y-%m-%d")
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_PATH/${DB_NAME}_backup_$TIMESTAMP.sql"
LOG_FILE="$BACKUP_PATH/backup_log_$TIMESTAMP.txt"

# Step 0: Create the temporary backup directory
echo "Creating backup directory: $BACKUP_PATH"
mkdir -p $BACKUP_PATH

# Step 1: Backup the MySQL database using mysqldump
echo "Starting MySQL database backup: $DB_NAME"
mysqldump --user=$DB_USER --password=$DB_PASSWORD $DB_NAME > $BACKUP_FILE

# Check if the backup succeeded
if [ $? -eq 0 ]; then
  echo "MySQL backup completed successfully."
else
  echo "Error during MySQL backup" | tee -a $LOG_FILE
  exit 1
fi

# Step 2: Upload the backup file to S3
echo "Uploading $BACKUP_FILE to S3 bucket: $S3_BUCKET"
aws s3 cp $BACKUP_FILE $S3_BUCKET

# Check if the upload succeeded
if [ $? -eq 0 ]; then
  echo "Backup successfully uploaded to S3." | tee -a $LOG_FILE
else
  echo "Error uploading to S3" | tee -a $LOG_FILE
  exit 1
fi

# Step 3: Remove the temporary backup directory and its contents
echo "Removing temporary backup directory: $BACKUP_PATH"
rm -rf $BACKUP_PATH

# Log completion
echo "Backup script completed at $(date)" | tee -a $LOG_FILE
