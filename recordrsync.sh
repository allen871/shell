#!/bin/bash

#同步web003录音到本地

remoteDir="/root/test"
dir="/root/tt/data"
localDir="/root/tt/record/"
dirFile="$dir"/file.txt
dirDir="$dir"/dir.txt

i=0
while [ $i == 0 ]
do
    ssh root@192.168.5.146 "ls --full-time /root/test/" > "$dirFile"
    
    > "$dirDir"
    
    cat "$dirFile" | awk 'BEGIN{getline}{print $6$7,$9}' | while read line
    do
        dirTimeNew=`echo $line | awk '{print $1}'`
        fileName=`echo $line | awk '{print $2}'`
        dirFileName="$dir"/"$fileName"
        if [ ! -f $dirFileName ];then
       	    echo $dirTimeNew > $dirFileName
            echo $fileName >> "$dirDir"
        fi
        dirTimeOld=`cat $dirFileName`
        if [ $dirTimeNew != $dirTimeOld ];then
    	    echo $fileName >> "$dirDir"
            echo $dirTimeNew > $dirFileName
        fi 
    done
    
    if [ -s "$dirDir" ];then
        cat "$dirDir" | while read line1
        do
            rsync -avc root@192.168.5.146:$remoteDir/$line1 $localDir
    
            files=`ls -l $localDir.$line1 | awk 'BEGIN{getline}{print $NF}' | awk -F "." '{print $1}' | sort | uniq -u`
            for file in $files
            do
    	        fileMp3="$localDir"."$line1"/"$file".mp3
                fileAmr="$localDir"."$line1"/"$file".amr
                if [ ! -f "$fileMp3" ];then
                    ffmpeg -i $fileAmr $fileMp3
    	    fi
            done
    
        done
    fi
    sleep 3
done
