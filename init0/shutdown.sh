#!/bin/bash

REGION="us-west-1"

## Getting the ec2 metadata
echo "fetching ec2 metadata from $REGION"
until /usr/bin/ec2metadata | tee /tmp/meta; do :; done

## Getting the instance_id
echo "fetching instance id from /tmp/meta"
instance_id=$(awk -F': ' "/instance-id/"'{print $2}' /tmp/meta)
echo "instance-id: $instance_id"

### Getting the tags
echo "getting tags for $instance_id from $REGION"
until /usr/local/bin/aws ec2 describe-tags --filters "Name=resource-id,Values=$instance_id" --region="$REGION" --output=text | tee /tmp/tags; do :; done

### Getting the tags:shutdown_today
echo "AWKing the tags from /tmp/tags"
shutdown_today=$(/usr/bin/awk "/shutdown_today/"'{print $5}' < /tmp/tags)
echo "tags:shutdown_today=$shutdown_today"


### checking the shutdown_today value
echo "checking the shutdown_today value"
if [ "$shutdown_today" = "False" ]
then
    echo "Do not shutdown"
    exit 1
else
    echo "/sbin/init 0"
    /sbin/init 0
    exit 0
fi
