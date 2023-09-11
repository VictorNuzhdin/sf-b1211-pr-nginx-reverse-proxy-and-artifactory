#!/bin/sh

SCRIPTS_PATH=/home/ubuntu/scripts
CONFIGS_PATH=/home/ubuntu/scripts/configs/nginx__v3
LOG_PATH=$SCRIPTS_PATH/configure_06-nginx-proxy-gw2.log
NEW_USER_LOGIN=devops
WEBSITE_DOMAIN_NAME=gw2.dotspace.ru


##--STEP#06 :: Configuring Nginx as reverse proxy gateway for access to Java Webapps
##  https://www.digitalocean.com/community/tutorials/how-to-configure-jenkins-with-ssl-using-an-nginx-reverse-proxy-on-ubuntu-22-04
##  https://katepratik.medium.com/nginx-tomcat-9-on-ubuntu-18-04-e5bf38e3b547
##  https://www.atlantic.net/vps-hosting/how-to-setup-tomcat-with-nginx-as-a-reverse-proxy-on-ubuntu-18-04/
##  https://stackoverflow.com/questions/19866203/nginx-configuration-to-pass-site-directly-to-tomcat-webapp-with-context
##  https://habr.com/ru/articles/434010/
##
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs started.." > $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "" >> $LOG_PATH


echo '## Step01 - Stopping Nginx..'
echo '## Step01 - Stopping Nginx..' >> $LOG_PATH
sudo systemctl stop nginx
echo ""
echo "" >> $LOG_PATH

echo '## Step02 - Backuping current configuration files and copying NEW ones..'
echo '## Step02 - Backuping current configuration files and copying NEW ones..' >> $LOG_PATH
##..backuping current configs
##  */var/www/gw2.dotspace.ru/html/index.html
##  */etc/nginx/sites-available/gw2.dotspace.ru
sudo mv /var/www/$WEBSITE_DOMAIN_NAME/html/index.html /var/www/$WEBSITE_DOMAIN_NAME/html/index.html_backup_$(date +'%Y%m%d_%H%M%S')
sudo mv /etc/nginx/sites-available/$WEBSITE_DOMAIN_NAME /etc/nginx/sites-available/$(echo $WEBSITE_DOMAIN_NAME)_backup_$(date +'%Y%m%d_%H%M%S')
##..copying new configs
sudo cp $CONFIGS_PATH/index.html /var/www/$WEBSITE_DOMAIN_NAME/html/
sudo cp $CONFIGS_PATH/$WEBSITE_DOMAIN_NAME /etc/nginx/sites-available/
sudo chown -R $NEW_USER_LOGIN:$NEW_USER_LOGIN /var/www/$WEBSITE_DOMAIN_NAME/html
sudo chmod -R 755 /var/www/$WEBSITE_DOMAIN_NAME
echo ""
echo "" >> $LOG_PATH

echo '## Step03 - Testing NEW configuration files and restarting Nginx..'
echo '## Step03 - Testing NEW configuration files and restarting Nginx..' >> $LOG_PATH
sudo nginx -t >> $LOG_PATH
echo ""
echo "" >> $LOG_PATH
sudo systemctl restart nginx
sudo systemctl status nginx | grep Active | awk '{$1=$1;print}'
sudo systemctl status nginx | grep Active | awk '{$1=$1;print}' >> $LOG_PATH
echo ""
echo "" >> $LOG_PATH

echo '## Step04 - Checking NEW configuration files (index.html)..'
echo '## Step04 - Checking NEW configuration files (index.html)..' >> $LOG_PATH
sudo cat /var/www/$WEBSITE_DOMAIN_NAME/html/index.html
sudo cat /var/www/$WEBSITE_DOMAIN_NAME/html/index.html >> $LOG_PATH
echo ""
echo "" >> $LOG_PATH

echo '## Step05 - Checking NEW default website configuration..'
echo '## Step05 - Checking NEW default website configuration..' >> $LOG_PATH
sudo cat /etc/nginx/sites-enabled/$WEBSITE_DOMAIN_NAME
sudo cat /etc/nginx/sites-enabled/$WEBSITE_DOMAIN_NAME >> $LOG_PATH
echo ""
echo "" >> $LOG_PATH

echo '## Step06 - Checking website and webpage availability..'
echo '## Step06 - Checking website and webpage availability..' >> $LOG_PATH
echo "[$WEBSITE_DOMAIN_NAME] ($(curl -s 2ip.ru))"
echo "[$WEBSITE_DOMAIN_NAME] ($(curl -s 2ip.ru))" >> $LOG_PATH
echo http__status [$WEBSITE_DOMAIN_NAME]: $(curl --silent --output /dev/null --write-out "%{http_code}" http://$WEBSITE_DOMAIN_NAME)
echo https_status [$WEBSITE_DOMAIN_NAME]: $(curl --silent --output /dev/null --write-out "%{http_code}" https://$WEBSITE_DOMAIN_NAME)
echo http__status [$WEBSITE_DOMAIN_NAME]: $(curl --silent --output /dev/null --write-out "%{http_code}" http://$WEBSITE_DOMAIN_NAME) >> $LOG_PATH
echo https_status [$WEBSITE_DOMAIN_NAME]: $(curl --silent --output /dev/null --write-out "%{http_code}" https://$WEBSITE_DOMAIN_NAME) >> $LOG_PATH
echo ""
echo "" >> $LOG_PATH
curl -s https://$WEBSITE_DOMAIN_NAME | grep title | awk '{$1=$1;print}'
curl -s https://$WEBSITE_DOMAIN_NAME | grep title | awk '{$1=$1;print}' >> $LOG_PATH
echo ""
echo "" >> $LOG_PATH


echo "" >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs done!" >> $LOG_PATH
