#!/bin/sh

SCRIPTS_PATH=/home/ubuntu/scripts
LOG_PATH=$SCRIPTS_PATH/configure_02-packages.log





##--STEP#02 :: Installing packages :: Python
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs started.." >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "" >> $LOG_PATH

#sudo apt update -y
#sudo apt upgrade -y                             ## Need to get 113 MB of archives.. т.е это будет долго (минут 5 и потом будет интерактивное окно и нужна перезагрузка)
#sudo apt install -y python3                     ## в образе от 2023.08.28 уже есть Python 3.10.12, обновление системы не меняет версию Python
#sudo apt -y autoremove >> $LOG_PATH             ## After this operation, 596 MB disk space will be freed.

echo "" >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs done!" >> $LOG_PATH
