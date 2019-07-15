#!/bin/ksh
#set -x
# result= df -k . | awk ' { print $2} ' | tail -1
if [ "$#" -ne 3 ] 
    then
    echo "illegal number of parameters it should be like following "
    echo "./check_tbsize.ksh User password Database "
    else
echo "   \n ############################################################
 Time of excuting the script is `date`
 ############################################################" |tee final_decision.log
fs_used_kb=`df -k . | grep "used allocated Kb" | awk ' { print $1} '`
fs_used_mb="$(printf  $(($fs_used_kb /1024 )))"
fs_total_kb=`df -k . | grep " total allocated Kb"  | awk ' { print $5} '`
fs_total_mb="$(printf  $(($fs_total_kb /1024 )))"
fs_total_mb_percent_15="$(printf  $(($fs_total_mb * 15/100 )))"
printf "\n File System used  $fs_used_mb MB \n" 
printf "\n Total File System $fs_total_mb MB \n" 
printf "\nTable space,Size  of database $3 \n" |tee -a final_decision.log
sqlplus -s <<! |tee -a final_decision.log
$1/$2@$3
set linesize 100
set pagesize 200
@TBS_SIZE.sql 
!

printf "\n ###### The decision regarding table Spaces ######\n" |tee -a final_decision.log

file=TBS_SIZE.out
while read line  ; do
  tp=$( echo "$line" |cut -f1 -d,)
  ts=$( echo "$line" |cut -f2 -d,)
if [ -z "$ts" ]
then
echo "bad values" >> /dev/null
else
  decision="$(printf  $((ts/10+fs_used_mb)))"
  if [ "$decision" -lt "$fs_total_mb_percent_15" ]
  then 
  printf "\n >> You  can Increase table space size for Table Space "$tp" \n" |tee -a final_decision.log
  else
  echo "\n >> You can do nothing for table space "$tp" \n"  |tee -a final_decision.log
  fi
  printf "\n *** Data Files of table space $tp , Size of the data file *** \n"
sqlplus -s $1/$2@$3 <<!  |tee -a final_decision.log
@DBFILE_SIZE.sql $tp
!
printf "\n *** The smallest Datafile for Tablsace *** \n" |tee -a final_decision.log
printf "\n The smallest Datafile for Tablsace $tp \n" |tee -a final_decision.log
output=`sed  "/^ *$/d" ${tp}_DBFILES.out  | grep -v rows | tail -1 ` 
if [ -z "$output" ]
then 
 printf "\n there is no data files\n" |tee -a final_decision.log
 else
 printf "\n $output \n" |tee -a final_decision.log
df=$( sed  "/^ *$/d" ${tp}_DBFILES.out  | grep -v rows | tail -1 |cut -f2 -d,)
decision2="$(printf  $(($df/10+fs_used_mb)))"
 if [ "$decision2" -lt "$fs_total_mb_percent_15" ]
then
printf "\n >> You  can Increase datafile size to "$decision2"    \n" |tee -a final_decision.log
  else
printf "\n >> You can do nothing for this data file \n"  |tee -a final_decision.log
  fi
fi
fi
done < ${file}

rm -rf *.out
fi
