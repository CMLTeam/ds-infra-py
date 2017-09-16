#!/usr/bin/env bash

# pre-requisite 1: repo is checked out in $APP folder (master branch)
# pre-requisite 2: pip installed
# pre-requisite 2: virtualenv installed

set -x

USER=apps1
SERV=prod.cmlteam.com
APP=ds-infra-py
PYTHON=python2
LOGFILE=.log
PIDFILE=.pid
DEPLOYVENV=.Python

ssh -i /tmp/deploy_rsa $USER@$SERV "
    export LC_ALL=C # for pip
    cd $APP
    echo "" >> $LOGFILE
    echo \"[`/bin/date +"%Y-%m-%d %H:%M:%S"`] ------- Redeploy started ------- \" >> $LOGFILE
    echo "" >> $LOGFILE
    if [ -f \"$PIDFILE\" ]
    then
        pid=\$(cat $PIDFILE)
        if [ ! -z \"\$pid\" ]
        then
            echo \"Killing PID=\$pid\" >> $LOGFILE 2>&1
            kill -9 \$pid >> $LOGFILE 2>&1
        fi
    fi
    git pull >> $LOGFILE 2>&1
    if [ ! -d \"$DEPLOYVENV\" ]
    then
        ~/.local/bin/virtualenv $DEPLOYVENV >> $LOGFILE 2>&1
    fi
    . $DEPLOYVENV/bin/activate
    pip install -r requirements.txt >> $LOGFILE 2>&1
    nohup $PYTHON server.py >> $LOGFILE 2>&1 &
    pid=\$!
    echo \"Started PID=\$pid\" >> $LOGFILE 2>&1
    echo \$pid > $PIDFILE
"