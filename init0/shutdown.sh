#!/bin/bash
echo "please find the log at /tmp/shutdown.log"
exec 2>&1 > /tmp/shutdown.log

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
REGION="us-west-1"
META=/tmp/meta
TAGS=/tmp/tags

##### SHUTDOWN CONDITIONS
function time_to_int(){

    hours=$(echo $1 | awk -F':'  '{print $1}')
    minutes=$(echo $1 | awk -F':'  '{print $2}')
    minutes=$(expr $hours \* 60 + $minutes )
    echo $minutes
}

SHUTDOWN_TIME=$(time_to_int 13:15)
CURRENT_TIME=$(time_to_int `date +%H:%M`)


## Getting the ec2 metadata
echo "fetching ec2 metadata from $REGION..."
until ec2metadata | tee $META; do :; done

## Getting the instance_id
echo
echo
echo "fetching instance id from $META..."
instance_id=$(awk -F': ' "/instance-id/"'{print $2}' $META)
echo "instance-id: $instance_id"

### Getting the tags
echo
echo
echo "getting tags for $instance_id from $REGION..."
until aws ec2 describe-tags --filters "Name=resource-id,Values=$instance_id" --region="$REGION" --output=text | tee $TAGS; do :; done

### AWKing the tags:shutdown_today
echo
echo
echo "AWKing the tags from $TAGS..."
SHUTDOWN_TODAY=$(awk "/shutdown_today/"'{print $5}' < $TAGS)
echo "Found tags:shutdown_today=$SHUTDOWN_TODAY"

### Do or Die 
echo
echo
echo "DO or Die ..."
echo "shutdown time: $SHUTDOWN_TIME current time:$CURRENT_TIME"

if [ "$CURRENT_TIME" -ge "$SHUTDOWN_TIME" ]
then

    if [ "$SHUTDOWN_TODAY" = "False" ]
    then
	echo "Do not Shutdown"
	exit 1;
    else
	echo "init 0"
	/sbin/init 0
	exit 0;
    fi
else
    echo "Not the time to Shutdown the Instance"
    exit 3;
fi
