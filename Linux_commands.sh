TARGET_FOLDER="/destination/path/to/copy"

#fk-search-ranking

BOX_IP=127.0.0.1

scp -o "StrictHostKeyChecking=no" -i ./$filename -r $REPO_NAME/path/* fk-search-ranking@$BOX_IP:${TARGET_FOLDER} 

scp -o "StrictHostKeyChecking=no" -i ./$filename -r $REPO_NAME/path/* fk-search-ranking@$BOX_IP:${TARGET_FOLDER}

#clean up 
##################################################################
##!/usr/bin/env bash

df -kH | grep '/dev/vda1' | awk '{ print $5 " " $1 }' | while read output;
do
date=`date -d '-3 day' '+%d'`
usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1 )

if [ $usep -ge 75 ]; then
sudo apt-get clean;
sudo find /var/log/ -type f -size +10M | xargs du -sh | sort -h | xargs sudo truncate -s 2M;
sudo find /home -type f -size +10M | xargs du -sh | sort -h | xargs sudo truncate -s 5M;
> /dev/null 2>&1
fi
done

###################################################################

####
mlid=$(echo $path | jq -r '.["model_id"]')
mlversions=$(echo $path | jq -r '.["model_version"]')
####################################



