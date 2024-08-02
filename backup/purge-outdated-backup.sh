#!/bin/bash
cd "$(dirname "$0")"

max_keep_count=$(sed '/^max_keep_count=/!d;s/.*='// ../config)
backup_remote_dir=$(sed '/^backup_remote_dir=/!d;s/.*='// ../config)
count=$(../utils/ossgbc)
backups=$(../utils/ossls $backup_remote_dir/ -d | grep $backup_remote_dir/2)
if [[ $max_keep_count < 0 ]];
then
	echo bad max_keep_count
	exit
fi
if [[ $count -gt $max_keep_count || $count == $max_keep_count ]];
then
	array=(${backups//\n/ })
	len=${#array[@]}
	endp=$(expr $len - 5)
	for e in $(seq 0 $endp)
        do
                ../utils/ossrmrf "${array[$e]}"
        done
fi
