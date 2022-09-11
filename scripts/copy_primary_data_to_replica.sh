#!/bin/bash
set -e
dt=$(date '+%d/%m/%Y %H:%M:%S');
echo "$dt - Attempting to copy Primary DB to Replica DB...";
if [ -z "$(ls -A $PGDATA)" ]; then
    echo "$dt - Copying Primary DB to Replica DB folder: $PGDATA";
    pg_basebackup -R -h $PRIMARY_HOST_NAME -D $PGDATA -P -U replication;
    if [ $UID == 0 ]
    then
    chown -R postgres:postgres $PGDATA;
    fi
    echo "$dt - Copy completed";
else
    echo "$dt - Skipping copy from Primary DB because Replica DB already exists";
fi
