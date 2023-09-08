#!/bin/sh

SCRIPTS_PATH=/home/ubuntu/scripts
CONFIGS_PATH=/home/ubuntu/scripts/configs
LOG_PATH=$SCRIPTS_PATH/configure_03-tomcat.log
#NEW_USER_LOGIN=devops
#SITE_NAME=repo.dotspace.ru


##--STEP#03 :: Installing and Configuring Apache Tomcat (webserver / servlets container)
##
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs started.." >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "" >> $LOG_PATH


echo '## Step00 - Update System packages list..' >> $LOG_PATH
sudo apt update >> $LOG_PATH
echo "" >> $LOG_PATH


echo '## Step01 - Installing Java SDK (17)..'
echo '## Step01 - Installing Java SDK (17)..' >> $LOG_PATH
##..installing OpenJDK
#sudo sudo apt install -y openjdk-17-jdk >> $LOG_PATH
#sudo apt install -y openjdk-17-jre >> $LOG_PATH
#
##..installing Oracle JDK
sudo apt install -y libc6-x32 libc6-i386 >> $LOG_PATH
wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.deb
sudo dpkg -i jdk-17_linux-x64_bin.deb
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk-17-oracle-x64/bin/java 1
echo "" >> $LOG_PATH
#
##..checkout (to console)
java --version
echo ""
##..checkout (to logfile)
ls jdk-17_linux-x64_bin.deb >> $LOG_PATH
ls -ll /usr/bin/java >> $LOG_PATH
echo "" >> $LOG_PATH
java --version >> $LOG_PATH
echo "" >> $LOG_PATH


echo '## Step02 - Configuring Tomcat User..'
echo '## Step02 - Configuring Tomcat User..' >> $LOG_PATH
sudo useradd -r -m -d /opt/tomcat -U -s /bin/false tomcat
##..checkout (to console)
id tomcat
ls -la /opt | grep tomcat
echo ""
##..checkout (to logfile)
id tomcat >> $LOG_PATH
ls -la /opt | grep tomcat >> $LOG_PATH
echo "" >> $LOG_PATH


echo '## Step03 - Installing/Unpacking Apache Tomcat (9.0.80) distro..'
echo '## Step03 - Installing/Unpacking Apache Tomcat (9.0.80) distro..' >> $LOG_PATH
wget -c https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.80/bin/apache-tomcat-9.0.80.tar.gz
wget -c https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.80/bin/apache-tomcat-9.0.80-fulldocs.tar.gz
sudo tar xzvf apache-tomcat-9.0.80.tar.gz -C /opt/tomcat --strip-components=1
sudo mkdir /opt/tomcat/doc
sudo tar xzvf apache-tomcat-9.0.80-fulldocs.tar.gz -C /opt/tomcat/doc --strip-components=1
##..checkout (to console)
ls -1X ~
echo ""
ls -la /opt | grep tomcat
##..checkout (to logfile)
ls -1X ~ >> $LOG_PATH
echo "" >> $LOG_PATH
ls -la /opt | grep tomcat >> $LOG_PATH
echo "" >> $LOG_PATH


echo '## Step04 - Configuring Tomcat Web UI Access..'
echo '## Step04 - Configuring Tomcat Web UI Access..' >> $LOG_PATH
##..backuping current webapp configs (renaming)
sudo mv /opt/tomcat/conf/tomcat-users.xml /opt/tomcat/conf/tomcat-users_xml_default
sudo mv /opt/tomcat/webapps/manager/META-INF/context.xml /opt/tomcat/webapps/manager/META-INF/context_xml_default
sudo mv /opt/tomcat/webapps/host-manager/META-INF/context.xml /opt/tomcat/webapps/host-manager/META-INF/context_xml_default
sudo mv /opt/tomcat/webapps/docs/META-INF/context.xml /opt/tomcat/webapps/docs/META-INF/context_xml_default
sudo mv /opt/tomcat/webapps/examples/META-INF/context.xml /opt/tomcat/webapps/examples/META-INF/context_xml_default
##..copying new webapp configs (replacing)
sudo cp $CONFIGS_PATH/tomcat-users.xml /opt/tomcat/conf/tomcat-users.xml
sudo cp $CONFIGS_PATH/manager/context.xml /opt/tomcat/webapps/manager/META-INF/context.xml
sudo cp $CONFIGS_PATH/host-manager/context.xml /opt/tomcat/webapps/host-manager/META-INF/context.xml
sudo cp $CONFIGS_PATH/docs/context.xml /opt/tomcat/webapps/docs/META-INF/context.xml
sudo cp $CONFIGS_PATH/examples/context.xml /opt/tomcat/webapps/examples/META-INF/context.xml
echo "" >> $LOG_PATH


echo '## Step05 - Updating files Permissions after unpack distro..'
echo '## Step05 - Updating files Permissions after unpack distro..' >> $LOG_PATH
sudo chown -R tomcat:tomcat /opt/tomcat/
sudo chmod -R g+r /opt/tomcat/conf
sudo chmod g+x /opt/tomcat/conf
sudo find /opt/tomcat/bin/ -maxdepth 1 -type f -name "*.bat" -delete
sudo sh -c 'chmod +x /opt/tomcat/bin/*.sh'
##..checkout (to console)
sudo ls -la /opt/tomcat
echo ""
sudo ls -la /opt/tomcat | grep conf
sudo ls -la /opt/tomcat/conf | grep server.xml
echo ""
sudo ls -la --sort=extension /opt/tomcat/bin
echo ""
##..checkout (to logfile)
sudo ls -la /opt/tomcat >> $LOG_PATH
echo "" >> $LOG_PATH
sudo ls -la /opt/tomcat | grep conf >> $LOG_PATH
sudo ls -la /opt/tomcat/conf | grep server.xml >> $LOG_PATH
echo "" >> $LOG_PATH
sudo ls -la --sort=extension /opt/tomcat/bin >> $LOG_PATH
echo "" >> $LOG_PATH


echo '## Step06 - Creating a systemd Tomcat Service File..'
echo '## Step06 - Creating a systemd Tomcat Service File..' >> $LOG_PATH
##..copying new tomcat-service-unit config
sudo cp $CONFIGS_PATH/tomcat.service /etc/systemd/system/tomcat.service
##..checkout (to console)
sudo ls -la /etc/systemd/system/tomcat.service
echo ""
sudo cat /etc/systemd/system/tomcat.service
echo ""
##..checkout (to logfile)
sudo ls -la /etc/systemd/system/tomcat.service >> $LOG_PATH
echo "" >> $LOG_PATH
sudo cat /etc/systemd/system/tomcat.service >> $LOG_PATH
echo "" >> $LOG_PATH


echo '## Step07 - Starting and Enabling Tomcat Service..'
echo '## Step07 - Starting and Enabling Tomcat Service..' >> $LOG_PATH
sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl enable tomcat
##..checkout (to console)
#sudo systemctl status tomcat
#echo ""
sudo systemctl status tomcat | grep Active | awk '{$1=$1;print}'
echo ""
##..checkout (to logfile)
#sudo systemctl status tomcat >> $LOG_PATH
#echo "" >> $LOG_PATH
sudo systemctl status tomcat | grep Active | awk '{$1=$1;print}' >> $LOG_PATH
echo "" >> $LOG_PATH


#echo '## Step66 - Deploying webApp..' >> $LOG_PATH
##..
#echo "" >> $LOG_PATH


#echo '## Step77 - Checkout Installation (disabled)..' >> $LOG_PATH
##..
#echo "" >> $LOG_PATH


echo "" >> $LOG_PATH
echo "-----------------------------------------------------------------------------" >> $LOG_PATH
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: Jobs done!" >> $LOG_PATH
