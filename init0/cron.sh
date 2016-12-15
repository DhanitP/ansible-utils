#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"

GIT_DIR="/tmp/shutdown-utils"
BRANCH="master"
GIT_URL="git@github.com:cloudfactory/ansible-utils"
PLAY_PATH="init0/shutdown.yml"
LOG_PATH="/tmp/shutdown.log"

echo
echo "See the log in $LOG_PATH"
echo "Executing..."
echo "ansible-pull -d $GIT_DIR -C $BRANCH -U $GIT_URL $PLAY_PATH"
ansible-pull -d $GIT_DIR -C $BRANCH -U $GIT_URL $PLAY_PATH > /tmp/shutdown.log 2>&1
