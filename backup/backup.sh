#!/bin/bash
cd "$(dirname "$0")"

backup_remote_dir=$(sed '/^backup_remote_dir=/!d;s/.*='// ../oss.ini)
backup_local_dir=$(sed '/^backup_local_dir=/!d;s/.*='// ../oss.ini)
time=$(date "+%Y-%m-%d_%H:%M:%S")
./purge-outdated-backup.sh
../utils/osscp $backup_local_dir $backup_remote_dir/$time