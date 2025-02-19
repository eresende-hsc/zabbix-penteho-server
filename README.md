# Pentaho Server by API HTTP

## Overview

Template to monitor Pentaho Server by using API.  

It needs a script as described bellow.  

This template was developed to monitor a Pentaho Server running in a Linux Box.

This template was created inspired in [Zabbix-ScheduledTask](https://github.com/Iakim/Zabbix-ScheduledTask.git)

The intention was not to exaust the Pentaho Server monitoring, it is just the first step.


## Requirements

- Zabbix Agent 2
- jq
- yq

## Tested versions

This template has been tested on:
- Zabbix Server 6.0
- Pentaho Server 9.3.0

## Configuration

The configuration is very simple, first of all you need to install `jq` and `yq`.  
You have to do this according your distro.

> :warning: WARNING :warning:  
The setup must be executed as `root` or `sudo`.

## Setup
After installed `jq` and `yq`...

1. Create a directory inside zabbix client dir normally in `/etc/zabbix`.  
```bash
mkdir -p /etc/zabbix/scripts
```
2. Copy the script to the directory created.  
```bash
 wget -O /etc/zabbix/scripts/getjobs.sh https://raw.githubusercontent.com/eresende-hsc/zabbix-penteho-server/refs/heads/main/files/getjobs.sh  
 chown zabbix.zabbix /etc/zabbix/scripts/getjobs.sh  
 chmod 750 /etc/zabbix/scripts/getjobs.sh  
``` 

3. Setup the Script 
You will need to inform some informations to script can connect to API and get the informations.

```bash
 API_SERVER="[ IP OR HOSTNAME ]:[ PORT ]"
 USERPASS="[ PENTAHO USER ]:[ PASSWORD ]"
 ZABBIX_SERVER="[ ZABBIX SERVER ]"
 ZABBIX_NAME="[ HOSTNAME IN ZABBIX SERVER ]"
```

4. Create a `UserParameter` in zabbix agent
```bash
 echo 'UserParameter=pentahomonitoring[*],/etc/zabbix/scripts/getjobs.sh "$1" "$2"' > /etc/zabbix/zabbix_agent2.d/pentaho.conf
```
5. Restart de Zabbix Agent  
```bash
systemctl restart zabbix-agent2
```

6. Import the template on Zabbix Server  
 Download it and import as usually

7. Associate the template to host and wait.
 The template will discover the JOBs and collect the data associated as `Job Name`, `Job Status`, `Last Time Execution`, `Next Time Execution` and `Last Execution Status`.


### LLD rule Jobs discovery

|Name|Description|Type|Key and additional info|
|----|-----------|----|-----------------------|
|Discover Jobs|Discover Jobs on Pentaho Server|Zabbix Agent|`pentahomonitoring[discovertasks]`|


### Items Prototype 

|Name|Description|Type|Key and additional info|
|----|-----------|----|-----------------------|
| Task: {#JOBNAME}: Schedule Status | The Job Scheduler Status. It can be `Normal` or `Paused`| Zabbix Agent | `pentahomonitoring[ScheduleStatus,{#JOBNAME}]` |
|Task: {#JOBNAME}: Last Result|The last check job result. It can be `Running` or `Finished`| Zabbix Agent | `pentahomonitoring[TaskLastResult,{#JOBNAME}]` |
|Task: {#JOBNAME}: Last Run Time| The last time the job was executed. Format: `1970-01-01 00:00:00` | Zabbix Agent | `pentahomonitoring[LastRunTime,{#JOBNAME}]` |
|Task: {#JOBNAME}: Next Run Time| The Next time the job will be executed. Format: `1970-01-01 00:00:00` | Zabbix Agent | `pentahomonitoring[NextRunTime,{#JOBNAME}]` |


### Trigger Prototype

|Name|Description|Expression|Severity|Dependencies and additional info|
|----|-----------|----------|--------|--------------------------------|
|Task: {#JOBNAME}: Last Result is failed|If the Last Job Status was not `Running`, `Finished` or `null` it will be triggered. <p><p> The API documentation does not show the possible values... so when this template was created the value for a failed jobs was not clear. <p>The script sends this condition as `2`.|`last(/Pentaho Task Scheduled - Custom HSC/pentahomonitoring[TaskLastResult,{#JOBNAME}])=2`|Average||


# Contribution
Feel free to use and contribute... You can fork and improve this template and script.

`Do it at you own risc.`
