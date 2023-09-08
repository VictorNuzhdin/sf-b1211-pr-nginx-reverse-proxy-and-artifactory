#!/bin/sh

SCRIPTS_PATH=/home/ubuntu/scripts
LOG_PATH=$SCRIPTS_PATH/configure_66-firewall.log





##--STEP#66 :: Enabling and Configuring build-in Ubuntu 22.04 firewall (ufw)
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs started.." >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "" >> $LOG_PATH

echo '## Step00.1 - Set default ruleset..' >> $LOG_PATH
sudo ufw default deny incoming
sudo ufw default allow outgoing

echo '## Step00.2 - Disable IPv6 processing/rules..' >> $LOG_PATH
sudo cat /etc/default/ufw | grep "IPV6=" >> $LOG_PATH
sudo sed -i 's/IPV6=yes/IPV6=no/g' /etc/default/ufw
sudo cat /etc/default/ufw | grep "IPV6=" >> $LOG_PATH
echo "" >> $LOG_PATH

echo '## Step01 - Allow incoming SSH..' >> $LOG_PATH
sudo ufw allow 22

echo '## Step02 - Allow incoming HTTP/S for Apache Tomcat webserver and Services..' >> $LOG_PATH
sudo ufw allow 80 comment 'Allow HTTP'
sudo ufw allow 443 comment 'Allow HTTPS'
sudo ufw allow 8070 comment 'Allow Artifactory UI'
sudo ufw allow 8080 comment 'Allow Tomcat HTTP)'
sudo ufw allow 8443 comment 'Allow Tomcat HTTPS)'

echo '## Step66 - Enabling firewall..' >> $LOG_PATH
ufw --force enable
echo "" >> $LOG_PATH

echo '## Step77 - Getting firewall status..' >> $LOG_PATH
sudo ufw status >> $LOG_PATH
echo "" >> $LOG_PATH

echo "" >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs done!" >> $LOG_PATH
