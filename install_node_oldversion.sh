#!/bin/bash
echo "node_exporter_installerByThiraphong"
echo "please run this script as root"
echo "log file is create on /var/log/node_exporterv1.0.1.log"

echo "create log file"
log="/var/log/node_exporter_v1.0.1_install.log"
sudo touch $log  
sudo chmod 777 $log
if [ $? -ne 0 ]; then
   echo "ERROR: can't create log file."
   exit 1
fi

echo "create node_exporter_user"
sudo userdel -r node_exporter
sudo useradd -rs /bin/false node_exporter
if [ $? -ne 0 ]; then
   echo "ERROR: create node_exporter_user"
   sudo echo "ERROR: create node_exporter_user" >> $log
   exit 1
fi

echo "create install folder."
install_path="$HOME/node_export_v1.0.1"
if [ -d $install_path ] 
then
    echo "ERROR: node_exporter folder is alreadyexists."
    sudo echo "ERROR: node_exporter folder is alreadyexists." >> $log 
    exit 1
fi
sudo mkdir $install_path
if [ $? -eq 0 ]; then 
   echo "move to install folder"
   cd $install_path
   echo "download file from github"
   sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
   if [ $? -ne 0 ]; then	
      echo "ERROR: wget file error"
      sudo echo "ERROR: wget file error" >> $log
      exit 1
   fi
   echo "extract tar.gz file"
   sudo tar xvfz node_exporter-1.0.1.linux-amd64.tar.gz
   if [ $? -eq 0 ]; then    
      echo "copy node_exporter to /usr/local/bin"
      sudo cp node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin
      if [ $? -ne 0 ]; then
         echo "ERROR: copy node_exporter to /usr/local/bin"
         sudo echo "ERROR: copy node_exporter to /usr/local/bin" >> $log
         exit 1
      fi
      echo "give permistion to node_exporter_user"
      sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
      if [ $? -ne 0 ]; then
         echo "ERROR: give permistion to node_exporter_user"
         sudo echo "ERROR: give permistion to node_exporter_user" >> $log
         exit 1
      fi
      echo "systemctl config"
      sudo node_exporter & 
      if [ $? -ne 0 ]; then
         echo "ERROR: start node_exporter"
         sudo echo "ERROR: start node_exporter" >> $log
      	 exit 1
      fi
      (crontab -l 2>/dev/null; echo "@reboot /usr/local/bin/node_exporter &") | crontab -
      if [ $? -ne 0 ]; then
         echo "ERROR: enable node_exporter on boot"
         sudo echo "ERROR: enable node_exporter on boot" >> $log
      	 exit 1
      fi
   fi	
fi



