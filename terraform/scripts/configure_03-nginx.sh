#!/bin/sh

SCRIPTS_PATH=/home/ubuntu/scripts
LOG_PATH=$SCRIPTS_PATH/configure_03-nginx.log





##--STEP#03 :: Installing and Configuring Nginx as reverse proxy gateway
##  https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-22-04
##  https://www.digitalocean.com/community/tutorials/how-to-configure-jenkins-with-ssl-using-an-nginx-reverse-proxy-on-ubuntu-22-04
##
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs started.." >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "" >> $LOG_PATH

echo '## Step01 - Installing Nginx..' >> $LOG_PATH
sudo apt install -y nginx
echo "" >> $LOG_PATH

echo '## Step01 - Installing Nginx..' >> $LOG_PATH
sudo apt install -y nginx
echo "" >> $LOG_PATH

echo '## Step77 - Checking Nginx..' >> $LOG_PATH
echo $(nginx -V &> info && cat info | head -n 2 >> $LOG_PATH) && rm info

whereis nginx >> $LOG_PATH
systemctl status nginx | grep Active >> $LOG_PATH

echo "" >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs done!" >> $LOG_PATH
