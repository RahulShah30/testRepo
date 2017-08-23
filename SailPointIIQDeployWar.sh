#!/bin/sh
# Following script with install sailpoint iiq by using a war file. Script will also verify whether java & apache tomcat are available before installing sailpoint iiq. If java & tomcat are not available then it will first install them & will proceed with iiq installation.
# This script will be available on IIQ box & will be called by master script from Jenkins.
set -e

ENV_NAME=$1

COMPONENT_NAME=$2

JAVA_NAME=$3

JAVA_INSTALL_NAME=$4

APP_INSTALL_PATH=$5

APP_SERVER_NAME=$6

APP_SERVER_INSTALL_NAME=$7

SAILPOINT_NAME=$8

SAILPOINT_INSTALL_PATH=$APP_INSTALL_PATH/$APP_SERVER_NAME/webapps/identityiq

PROP_FILE=iiq.properties

INSTALLER_PATH=$9

HOST_NAME=${10}

INSTALL_IIQ_SCHEMA=${11}

IIQ_VERSION=${12}

DB_NAME=${13}

DB_HOST=${14}

DB_USER=${15}

DB_PASSW=${16}

DB_TYPE=${17}

UI_Task_Server=${18}

LOG_LEVEL=${19}
install_db_schema="false"
hostName=$(hostname)
iiqHome=""

echo "Env Name --> "$ENV_NAME
echo "Component Name --> "$COMPONENT_NAME
echo "Java Name --> "$JAVA_NAME
echo "Java Installer Name --> "$JAVA_INSTALL_NAME
echo "Application Install Path --> "$APP_INSTALL_PATH
echo "Application Server --> "$APP_SERVER_NAME
echo "Application Server Installer Name --> "$APP_SERVER_INSTALL_NAME
echo "SailPoint Name -->" $SAILPOINT_NAME
echo "Installer Path --> "$INSTALLER_PATH
echo "Host Name --> "$HOST_NAME
echo "Install IIQ Schema --> "$INSTALL_IIQ_SCHEMA
echo "IIQ Version --> "$IIQ_VERSION
echo "Database Name --> "$DB_NAME
echo "Database Host --> "$DB_HOST
echo "Database User --> "$DB_USER
echo "Database Password --> "$DB_PASSW
echo "Database Type --> "$DB_TYPE
echo "UI/Task Server --> "$UI_Task_Server
echo "HostName --> "$hostName
echo "Log Level for "$ENV_NAME" -->"$LOG_LEVEL
echo " "

# This function will be executed first.
deploySailPoint()
{
  javaCheck
  appserverCheck
  sailpointCheck
}

# Below function will check for java availability & will install it if not available. 
javaCheck()
{
 echo "<<<<< Java Check Started on $HOST_NAME >>>>>"
 javaCheck=$(find $APP_INSTALL_PATH -name $JAVA_NAME) 
 echo "javaCheck--> "$javaCheck

 if [ -z "$javaCheck" ]
 then
      echo $JAVA_NAME "is not available on $HOST_NAME."
      echo "Need to install "$JAVA_NAME" on $HOST_NAME"
      installJava
      echo $JAVA_NAME " INSTALLED SUCCESSFULLY on $HOST_NAME"

 else
      echo $JAVA_NAME " exists on "$HOST_NAME
 fi
 RET_VAL=$?
 echo "RET_VAL --> "$RET_VAL
 echo "<<<<< Java Check Completed on $HOST_NAME >>>>>"
 echo " "
}

# Below function will check for tomcat availability & will install it if not available.
appserverCheck()
{
 echo "<<<<< AppServer Check Started on $HOST_NAME >>>>>"
 appserverCheck=$(find $APP_INSTALL_PATH -name $APP_SERVER_NAME)
 echo "appserverCheck --> "$appserverCheck

 if [ -z "$appserverCheck" ]
 then
      echo $APP_SERVER_NAME "is not available on $HOST_NAME"
      echo "Need to install " $APP_SERVER_NAME" on $HOST_NAME"
      installAppServer
      echo $APP_SERVER_NAME " INSTALLED SUCCESSFULLY on $HOST_NAME"
 else
      echo $APP_SERVER_NAME " exists on "$HOST_NAME
 fi
 RET_VAL=$?
 echo "RET_VAL --> "$RET_VAL
 echo "<<<<< AppServer Check Completed on $HOST_NAME >>>>>"
 echo " "
}

# Below function will check for iiq availability & will install it if not available.
sailpointCheck()
{
 echo "<<<<< SailPoint Check Started on $HOST_NAME >>>>>"
 sailpointCheck=$(find $APP_INSTALL_PATH -name $SAILPOINT_NAME)
 echo "sailpointCheck --> "$sailpointCheck

 if [ -z "$sailpointCheck" ]
 then
      echo $SAILPOINT_NAME "is not available on $HOST_NAME"
      echo "Need to install " $SAILPOINT_NAME" on $HOST_NAME"
      installSailPoint
      echo $SAILPOINT_NAME " INSTALLED SUCCESSFULLY on $HOST_NAME"
 else
      echo $SAILPOINT_NAME " exists on "$HOST_NAME
 fi
 RET_VAL=$?
 echo "RET_VAL --> "$RET_VAL
 echo "<<<<< SailPoint Check Completed on $HOST_NAME >>>>>"
 echo " "
}

# Below function will install java.
installJava()
{
 echo "<<<<< Java Installation Started on $HOST_NAME >>>>>"
 cp $INSTALLER_PATH/$JAVA_INSTALL_NAME.tar.gz $APP_INSTALL_PATH
 echo "Copied Successfully --> "$JAVA_INSTALL_NAME
 cd $APP_INSTALL_PATH/
 tar -xvf $APP_INSTALL_PATH/$JAVA_INSTALL_NAME.tar.gz
 echo "Completed Installing JAVA....."
 echo "Setting JAVA_HOME, JRE_HOME & PATH....."
 export JAVA_HOME=$APP_INSTALL_PATH/$JAVA_NAME
 export JRE_HOME=$APP_INSTALL_PATH/$JAVA_NAME/jre
 export PATH=$PATH:$APP_INSTALL_PATH/$JAVA_NAME/bin 
 echo "JAVA_HOME--> "$JAVA_HOME
 echo "JRE_HOME--> "$JRE_HOME
 echo "PATH--> "$PATH
 echo "Setting JAVA_HOME, JRE_HOME & PATH Completed....."
 chmod -R 777 $APP_INSTALL_PATH/$JAVA_NAME
 RET_VAL=$?
 echo "RET_VAL --> "$RET_VAL
 echo "<<<<< Java Installation Completed on $HOST_NAME >>>>>"
 echo " "
}

# Below function will install tomcat.
installAppServer()
{
 echo "<<<<< Apache Tomcat Installation Started on $HOST_NAME >>>>>" 
 cp $INSTALLER_PATH/$APP_SERVER_INSTALL_NAME.zip $APP_INSTALL_PATH
 echo "Copied Successfully--> " $APP_SERVER_INSTALL_NAME.zip
 cd $APP_INSTALL_PATH
 unzip $APP_INSTALL_PATH/$APP_SERVER_INSTALL_NAME.zip -d $APP_INSTALL_PATH
 RET_VAL=$?
 echo "RET_VAL --> "$RET_VAL
 echo "<<<<< Apache Tomcat Installation Completed on $HOST_NAME >>>>>"
 echo " "
}

# Below function will install iiq.
installSailPoint()
{
 echo "<<<<< SailPoint IIQ Installation Started on $HOST_NAME >>>>>"
 echo "Creating identityiq folder under webapps folder....."
 cd $APP_INSTALL_PATH/$APP_SERVER_NAME/webapps
 mkdir identityiq
 echo "identityiq folder created under webapps folder....."
 echo "Installing SailPoint IIQ....."
 cp $INSTALLER_PATH/$SAILPOINT_NAME.war $SAILPOINT_INSTALL_PATH
 echo jar -xvf  $SAILPOINT_NAME.war
 iiqHome=$APP_INSTALL_PATH/$APP_SERVER_NAME/webapps/identityiq
 cd $APP_INSTALL_PATH/$APP_SERVER_NAME/webapps/identityiq
 jar -xvf $SAILPOINT_NAME.war
 chmod -R 777 $APP_INSTALL_PATH/$APP_SERVER_NAME/webapps
 echo " "
 echo "<<<<< Starting Database Configuration >>>>>"
 if [ "$install_db_schema" != $INSTALL_IIQ_SCHEMA ]
 then
     echo "Starting with SailPoint IIQ Schema Creation....."
	 cd $APP_INSTALL_PATH/scripts
	 ./SailPointIIQInstallSchema.sh $APP_INSTALL_PATH/$APP_SERVER_NAME/webapps/identityiq/WEB-INF/database $IIQ_VERSION $DB_NAME $DB_HOST $DB_USER $DB_PASSW $APP_INSTALL_PATH $DB_TYPE
	 echo "Completed SailPoint IIQ Schema Creation....."	 
 else
     echo "IIQ Schema Creation is not required!!!!!"
 fi
 echo "<<<<< Completed Database Configuration >>>>>"
 echo " "
 cd $APP_INSTALL_PATH/$APP_SERVER_NAME/webapps/identityiq/WEB-INF/classes
 mv iiq.properties $INSTALLER_PATH/backup
 echo "Backup of iiq.properties done"
 echo "Copying new iiq.properties"
 cp $INSTALLER_PATH/$PROP_FILE $APP_INSTALL_PATH/$APP_SERVER_NAME/webapps/identityiq/WEB-INF/classes
 echo "New iiq.properties copied"
 echo "Starting SailPoint IIQ Configuration"
 echo "Starting IIQ Console"
sh $APP_INSTALL_PATH/$APP_SERVER_NAME/webapps/identityiq/WEB-INF/bin/iiq console <<!
import init.xml
echo "init.xml Import Completed....."

import $APP_INSTALL_PATH/$APP_SERVER_NAME/webapps/identityiq/WEB-INF/config/init-lcm.xml
echo "init-lcm file is imported....."
!
 echo "Completed SailPoint IIQ Configuration"
 echo "RET_VAL --> "$RET_VAL
 echo "<<<<< SailPoint IIQ Installation Completed on $HOST_NAME >>>>>"
 echo " "
 startTomcat
 setLogLevel
 initiateUITaskServerChanges
}

# Below function will start tomcat post iiq installation.
startTomcat()
{
 echo "<<<<< Starting Tomcat on $HOST_NAME >>>>>"
 echo "Starting Tomcat ......"
 cd $APP_INSTALL_PATH/$APP_SERVER_NAME/bin
 chmod 777 catalina.sh
 ./catalina.sh start
 RET_VAL=$?
 echo "RET_VAL --> "$RET_VAL
 echo "<<<<< Tomcat Started on $HOST_NAME >>>>>"
 echo " "
}

initiateUITaskServerChanges()
{
 echo "<<<<< initiateUITaskServerChanges-Start >>>>>"
 if [ ! -z "$UI_Task_Server" ] && [ "$hostName" == "$UI_Task_Server" ]
 then
     echo "Starting Configurations for UI/Task Server on $UI_Task_Server"
	 cd $APP_INSTALL_PATH/scripts
	 ./SailPointIIQEditUITaskXML.py $UI_Task_Server
	 chmod 777 ServiceDefinition*
	 export JAVA_HOME=$APP_INSTALL_PATH/$JAVA_NAME
     export JRE_HOME=$APP_INSTALL_PATH/$JAVA_NAME/jre
     export PATH=$PATH:$APP_INSTALL_PATH/$JAVA_NAME/bin
sh $APP_INSTALL_PATH/$APP_SERVER_NAME/webapps/identityiq/WEB-INF/bin/iiq console <<!
import $APP_INSTALL_PATH/scripts/ServiceDefinitionRequest.xml
echo "ServiceDefinitionRequest.xml file is imported....."

import $APP_INSTALL_PATH/scripts/ServiceDefinitionTask.xml
echo "ServiceDefinitionTask.xml file is imported....."
!
	 echo "Completed Configurations for UI/Task Server on $UI_Task_Server"
	 echo "<<<<< Check About Page under Debug for UI/Task Server Status >>>>>"	 
 else
     echo "UI/Task Server Configuration is not required"
 fi
 echo "<<<<< initiateUITaskServerChanges-Complete >>>>>"
}

setLogLevel()
{
 echo "<<<<< setLogLevel-Start >>>>>"
 echo "IIQ Home --> "$iiqHome
 cd $iiqHome/WEB-INF/classes
 fileName=log4j.properties
 echo "Log4j file location --> "$fileName
 
 if [ "$ENV_NAME" == "Dev" ] || [ "$ENV_NAME" == "DEV" ] || [ "$ENV_NAME" == "Test" ] || [ "$ENV_NAME" == "TEST" ]
 then
     #logLevelValue="trace"
	  logLevelValue=$LOG_LEVEL
 else
     #logLevelValue="fatal"
	 logLevelValue=$LOG_LEVEL
 fi
 
 keyName="log4j.rootLogger"
 oldValue=`cat ${fileName} | grep ${keyName} | cut -d'=' -f2`
 echo "Old Value for $keyName is $oldValue"
 
 sed -i "s/\($keyName *= *\).*/\1$logLevelValue/" $fileName
 echo "$fileName modified with $logLevelValue."
 
 echo "<<<<< setLogLevel-End >>>>>"
}
deploySailPoint