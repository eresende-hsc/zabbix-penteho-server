#!/bin/bash
# Dependences
# - jq
# - yq ( https://github.com/mikefarah/yq )

 export API_SERVER="[ IP OR HOSTNAME ]:[ PORT ]"
 export API_PATH="pentaho/api/scheduler/getJobs"
 export API_STATUS_PATH="pentaho/kettle/status/?xml=Y"
 export USERPASS="svc.zabbix:[ PASSWORD ]"
 export ZABBIX_SERVER="[ ZABBIX SERVER ]"
 export ZABBIX_NAME="[ HOSTNAME IN ZABBIX SERVER ]"
 export TEMP_FILE=$(mktemp -p /var/tmp/)

# Job Discovery
if [ "$1" == "discovertasks" ] ; then
 JOBS=$(curl -u $USERPASS -s -X GET "http://$API_SERVER/$API_PATH" | jq -r '.job[].jobName' )
IFS="
"
 echo "{\"data\":["
 for JOB in $JOBS; do
  echo {\"{#JOBNAME}\":\"$JOB\"},
 done | sed ':a;N;$!ba;s/\(.*\),/\1/'
 echo "]}"
fi

# Last RunTime for a JOB
if [ "$1" == "LastRunTime" ] ; then
IFS="
"
 JOB="$2"
 DATE=$(curl -u $USERPASS -s -X GET "http://$API_SERVER/$API_PATH"  | jq -r '.job[] | select(.jobName == '\"$JOB\"') | .lastRun' | head -n 1 )
 if [ "$DATE" != "null" ]; then
  date -d "$DATE" +"%s"
 else
  echo "0"
 fi
fi

# Schedule Status
if [ "$1" == "ScheduleStatus" ] ; then
IFS="
"
 JOB="$2"
 STATE=$(curl -u $USERPASS -s -X GET "http://$API_SERVER/$API_PATH"  | jq -r '.job[] | select(.jobName == '\"$JOB\"') | .state' | head -n 1)
 if   [ "$STATE" == "NORMAL" ] ; then
  echo "0"
 elif [ "$STATE" == "PAUSED" ] ; then
  echo "2"
 else
  # Any else status Jobs
  echo "1"
 fi
fi

# Last State for a Job
if [ "$1" == "TaskLastResult" ] ; then
IFS="
"
 JOB="$2"
 curl -u $USERPASS -s -X GET "http://$API_SERVER/$API_STATUS_PATH" > $TEMP_FILE
 STATE=$(yq -p=xml -o=json $TEMP_FILE  | jq '.serverstatus.jobstatuslist.jobstatus[] | select(.jobname == '\"$JOB\"' )  | .' | jq -r -s 'max_by(.log_date) | .status_desc' )

 if   [ "$STATE" == "Finished" ] ; then
  echo "0"
 elif [ "$STATE" == "Running" ] ; then
  echo "1"
 elif [ "$STATE" == "null" ] ; then
  echo "3"
 else
  # Any else status Jobs
  echo "2"
 fi
fi

# Next Schedule for a Job
if [ "$1" == "NextRunTime" ] ; then
IFS="
"
 JOB="$2"
 DATE=$(curl -u $USERPASS -s -X GET "http://$API_SERVER/$API_PATH"  | jq -r '.job[] | select(.jobName == '\"$JOB\"') | .nextRun' | head -n 1 )
 if [ "$DATE" != "null" ]; then
  date -d "$DATE" +"%s"
 fi
fi