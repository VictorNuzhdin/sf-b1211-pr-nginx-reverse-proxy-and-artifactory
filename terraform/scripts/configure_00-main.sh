#!/bin/sh

SCRIPTS_PATH=/home/ubuntu/scripts
LOG_PATH=$SCRIPTS_PATH/configure_00-main.log





##--STEP#00 :: Execution of individual scripts
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Scripts execution started.." >> $LOG_PATH
#
chmod +x $SCRIPTS_PATH/configure_01-users.sh
sudo bash $SCRIPTS_PATH/configure_01-users.sh
#
chmod +x $SCRIPTS_PATH/configure_02-packages.sh
sudo bash $SCRIPTS_PATH/configure_02-packages.sh
#
chmod +x $SCRIPTS_PATH/configure_03-nginx.sh
sudo bash $SCRIPTS_PATH/configure_03-nginx.sh
#
chmod +x $SCRIPTS_PATH/configure_77-getinfo.sh
sudo bash $SCRIPTS_PATH/configure_77-getinfo.sh
#
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Scripts execution done!" >> $LOG_PATH
