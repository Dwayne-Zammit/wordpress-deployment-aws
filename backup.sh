#!/bin/bash

# Configuration
DB_USER="your_db_user"
DB_PASSWORD="your_db_password"
DB_NAME="your_db_name"
BACKUP_DIR="/path/to/backup/directory"
DATE=$(date +'%Y%m%d%H%M')

# Create backup
mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_DIR/db_backup_$DATE.sql

# Optionally compress the backup
gzip $BACKUP_DIR/db_backup_$DATE.sql

# Print message
echo "Backup completed: $BACKUP_DIR/db_backup_$DATE.sql.gz"
