#!/bin/sh

find $MYSQL_DUMP_DIRECTORY/dump* -mtime +0 -exec rm {} \;

fileDt=$(date '+%Y_%m_%d_%H_%M_%S');
backUpFilePath="$MYSQL_DUMP_DIRECTORY/dump_$fileDt.gz"
mysqldump -h$MYSQL_HOST -uroot -p$MYSQL_ROOT_PASSWORD --force -A | gzip > $backUpFilePath
if [ $? -ne 0 ]; then
  rm $backUpFilePath
  echo "Unable to execute a BackUp. Please check DB connection settings"
  exit 1
fi
