#!/usr/bin/env bash

# pre-requisite 1: repo is checked out in $APP folder (master branch)
# pre-requisite 2: pip installed
# pre-requisite 2: virtualenv installed

set -x

USER=apps1
SERV=prod.cmlteam.com
APP=ds-infra-py
PYTHON=python2
DEPLOYLOG=.log
DEPLOYVENV=.Python

ssh -i /tmp/deploy_rsa $USER@$SERV "
    export LC_ALL=C # for pip
    > .log
    cd $APP
    git pull
    if [ -f .pid ]
    then
        kill -9 `cat .pid` >> $DEPLOYLOG 2>&1
    fi
    if [ ! -d $DEPLOYVENV ]
    then
        virtualenv $DEPLOYVENV >> $DEPLOYLOG 2>&1
    fi
    . .Python/bin/activate
    pip install -r requirements.txt >> $DEPLOYLOG 2>&1
    nohup $PYTHON server.py > /var/log/$APP.log 2>&1 &
    echo $! > .pid
"