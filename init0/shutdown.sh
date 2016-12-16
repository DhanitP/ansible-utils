#!/bin/bash

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"

REGION="us-west-1"
META=/tmp/meta
TAGS=/tmp/tags

## Getting the ec2 metadata
echo "fetching ec2 metadata from $REGION..."
until /usr/bin/ec2metadata | tee $META; do :; done

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
until /usr/local/bin/aws ec2 describe-tags --filters "Name=resource-id,Values=$instance_id" --region="$REGION" --output=text | tee $TAGS; do :; done

### AWKing the tags:shutdown_today
echo
echo
echo "AWKing the tags from $TAGS..."
shutdown_today=$(/usr/bin/awk "/shutdown_today/"'{print $5}' < $TAGS)
echo "Found tags:shutdown_today=$shutdown_today"

### Do or Die 
echo
echo
echo "DO or Die ..."
if [ "$shutdown_today" = "False" ]
then
    echo "Do not shutdown"
    exit 1
else
    echo "/sbin/init 0"
    /sbin/init 0
    exit 0
fi
