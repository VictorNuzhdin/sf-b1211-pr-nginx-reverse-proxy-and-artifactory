#!/bin/sh

SCRIPTS_PATH=/home/ubuntu/scripts
CONFIGS_PATH=/home/ubuntu/scripts/configs
LOG_PATH=$SCRIPTS_PATH/configure_07-tomcat-deploy-webapp.log

APP_NAME=repo
TOMCAT_USER=tomcat
WEBAPPS_SRC_PATH=$SCRIPTS_PATH/webapps
CATALINA_HOME=/opt/tomcat
CATALINA_HOME_WEBAPPS=$CATALINA_HOME/webapps



##--STEP#04 :: Deploying JavaEE Web Application..
##
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs started.." >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "" >> $LOG_PATH


echo '## Step00 - Checking initial state (before deploy)..'
echo '## Step00 - Checking initial state (before deploy)..' >> $LOG_PATH
##..checkout java version
java --version
javac --version
java --version >> $LOG_PATH
javac --version >> $LOG_PATH
echo ""
echo "" >> $LOG_PATH
##..checkout variables (to console)
echo "---"
echo "APP_NAME.............: $APP_NAME"
echo "WEBAPPS_SRC_DIR......: $WEBAPPS_SRC_DIR"
echo "CATALINA_HOME........: $CATALINA_HOME"
echo "CATALINA_HOME_WEBAPPS: $CATALINA_HOME_WEBAPPS"
echo "---"
##..checkout variables (to logfile)
echo "---" >> $LOG_PATH
echo "APP_NAME.............: $APP_NAME" >> $LOG_PATH
echo "WEBAPPS_SRC_DIR......: $WEBAPPS_SRC_DIR" >> $LOG_PATH
echo "CATALINA_HOME........: $CATALINA_HOME" >> $LOG_PATH
echo "CATALINA_HOME_WEBAPPS: $CATALINA_HOME_WEBAPPS" >> $LOG_PATH
echo "---" >> $LOG_PATH
##..checkout webapps source path
sudo ls -ll $WEBAPPS_SRC_PATH
sudo ls -ll $WEBAPPS_SRC_PATH >> $LOG_PATH
echo "---"
echo "---" >> $LOG_PATH
##..checkout webapps destination path
sudo ls -ll $CATALINA_HOME_WEBAPPS
sudo ls -ll $CATALINA_HOME_WEBAPPS >> $LOG_PATH
echo ""
echo "" >> $LOG_PATH


echo '## Step01 - Deploying NEW webApp instance..'
echo '## Step01 - Deploying NEW webApp instance..' >> $LOG_PATH
##..removing old webapp folder
sudo rm -rf $CATALINA_HOME_WEBAPPS/$APP_NAME
##..installing new webapp folder and fix files permission
sudo cp -R $WEBAPPS_SRC_PATH/$APP_NAME $CATALINA_HOME_WEBAPPS
sudo chown -R tomcat:tomcat $CATALINA_HOME_WEBAPPS/$APP_NAME
echo ""
echo "" >> $LOG_PATH


echo '## Step02 - Restarting Tomcat Service..'
echo '## Step02 - Restarting Tomcat Service..' >> $LOG_PATH
sudo systemctl restart tomcat
##..checkout (to console and logfile)
sudo systemctl status tomcat | grep Active | awk '{$1=$1;print}'
sudo systemctl status tomcat | grep Active | awk '{$1=$1;print}' >> $LOG_PATH
echo ""
echo "" >> $LOG_PATH


echo '## Step03 - Checking result state (after deploy)..'
echo '## Step03 - Checking result state (after deploy)..' >> $LOG_PATH
##..webapp destination path
sudo ls -ll $CATALINA_HOME_WEBAPPS
sudo ls -ll $CATALINA_HOME_WEBAPPS >> $LOG_PATH
echo ""
echo "" >> $LOG_PATH


echo "" >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs done!" >> $LOG_PATH
