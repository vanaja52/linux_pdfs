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

Ctrl + a	Move cursor to beginning of line
Ctrl + e	Move cursor to end of line
Ctrl + <right-arrow>	Move cursor to end of current word
Ctrl + <left-arrow>	Move cursor to beginning of current word
Ctrl + f	Move cursor to next letter
Ctrl + b	Move cursor to previous letter
Ctrl + d	Delete current letter
Ctrl + h	Delete previous letter
Ctrl + u	Cut line to the left of cursor
Ctrl + k	Cut line to the right of cursor
Ctrl + r Reverse search command history
Ctrl + w Cut one word to the left of cursor
Ctrl + l	Clear screen (similar to clear command)
Ctrl + t	Swap current and previous letter (this of correcting a typo)
Esc + t	Swap current and word
Ctrl + y Paste what was cut



