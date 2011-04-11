 #! /bin/bash

#################################
####Author: Gregory Anne      ###
####anne.gregory@ionetwork.com###
#################################

prev_revs_num=`awk '{print $1}' /consolidation/previous`
cur_revs_num=`awk '{print $1}' /var/www/html/svn/trunk/db/current`

echo "The script will backup revisions $prev_revs_num to $cur_revs_num"

filelimitdwn=$(((prev_revs_num / 1000) * 1000 + 1))
filelimitup=$(((cur_revs_num / 1000) * 1000 + 1000))

gap=$(($filelimitup - $filelimitdwn))

if [ $gap -gt 1000 ]; then
        ##Two different files
        middle000=$((filelimitdwn + 1000 - 1))
        middle1=$((filelimitdwn + 1000))
        file_one="${filelimitdwn}dump${middle000}.dump"
        file_two="${middle1}dump${filelimitup}.dump"
        svnadmin dump -r $filelimitdwn:$middle000 /var/www/html/svn/trunk/ --incremental  >        /consolidation/$file_one
        echo "Creating a new file..."
        svnadmin dump -r $middle1:$cur_revs_num /var/www/html/svn/trunk/ --incremental  >           /consolidation/$file_two
else
        ##Only one file
        file_one="${filelimitdwn}dump${filelimitup}.dump"
        svnadmin dump -r $filelimitdwn:$cur_revs_num /var/www/html/svn/trunk/ --incremental  >      /consolidation/$file_one
fi


#Finally update the 'previous' file
echo $cur_revs_num > /consolidation/previous

