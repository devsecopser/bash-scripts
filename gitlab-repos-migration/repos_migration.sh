#!/bin/bash
INPUT=gitlab_repos.csv
OLDIFS=$IFS
IFS=','
identifier_arg=$1
echo "What is your gitlab URL for source gitlab, ex: https://us-south.git.cloud.ibm.com ?"
read SOURCE_GITLAB
echo "What is your gitlab Access token for source gitlab ?"
read SOURCE_GITLAB_TOKEN
echo "What is your gitlab URL for destination gitlab, ex: https://us-south.git.cloud.ibm.com ?"
read DEST_GITLAB
echo "What is your gitlab Acess token for destination gitlab?"
read DEST_GITLAB_TOKEN
echo "What is your gitlab Acess token for destination gitlab?"
read DEST_GITLAB_TOKEN
echo "What is the namespace id for microservices of destination gitlab?"
read target_namespace_microservices
echo "What is the namespace id for devops of destination gitlab?"
read target_namespace_devops
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read id path path_new identifier target_namespace
do	
    if [ "$identifier" = "$identifier_arg" ] 
    then
        if [ "$target_namespace" = "microservices" ] 
        then
        echo "target_namespace is microservices"
		#namespace id is under its name on gitlab, it is a fixed number and should be set before running the script
        target_namespace_id=${target_namespace_microservices}
        elif [ "$target_namespace" = "devops" ] 
        then
        echo "target_namespace is devops"
        target_namespace_id=${target_namespace_devops}
        else
        echo "Unknown target_namespace, Please specify correct one"; exit 99 
        fi
    echo "exporting project $id $path $identifier  ..."
    curl --request POST --header "PRIVATE-TOKEN: $SOURCE_GITLAB_TOKEN" -k  ${SOURCE_GITLAB}/api/v4/projects/$id/export
    STATUS=`curl -s  --header "PRIVATE-TOKEN: $SOURCE_GITLAB_TOKEN" -k ${SOURCE_GITLAB}/api/v4/projects/$id/export |  python -c "import sys, json; print(json.load(sys.stdin)['export_status'])"`
    echo "project  $id $path export status is  $STATUS"
    COUNTER=1
    while [ "$STATUS" != "finished" ]
    do
    sleep 2
    STATUS=`curl -s  --header "PRIVATE-TOKEN: $SOURCE_GITLAB_TOKEN" -k ${SOURCE_GITLAB}/api/v4/projects/$id/export |  python -c "import sys, json; print(json.load(sys.stdin)['export_status'])"`
    COUNTER=$(( $COUNTER + 1 ))
    if [ $COUNTER -eq 10 ] 
    then
    echo "project  $id $path export status is  $STATUS , "; exit 88 
    fi
    done
    echo "downloading project $id $path $identifier  ..."
    curl -o ${id}.tar.gz --header "PRIVATE-TOKEN:  $SOURCE_GITLAB_TOKEN" --remote-header-name  --remote-name -k -Ss ${SOURCE_GITLAB}/api/v4/projects/${id}/export/download
    echo "Importing project $id $path $identifier to private gitlab  ..."
    curl --request POST --header "PRIVATE-TOKEN: $DEST_GITLAB_TOKEN" --form "namespace=$target_namespace_id" --form "path=$path_new" --form "file=@${id}.tar.gz" --form "overwrite=yes" -k ${DEST_GITLAB}/api/v4/projects/import
    else
    echo "$identifier and $identifier_arg are mismatch for $id $path"
    fi
done <  "$INPUT"
IFS=$OLDIFS