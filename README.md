
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Unresponsive MySQL service on pod with database lock.
---

This incident type refers to a situation where the MySQL service running on a pod becomes unresponsive and is unable to process new read and write requests. The incident could be caused by a database lock, which prevents other processes from accessing the database. The exact cause of the lock situation may need to be determined to resolve the issue.

### Parameters
```shell
export POD_NAME="PLACEHOLDER"

export MYSQL_CONTAINER_NAME="PLACEHOLDER"

export MYSQL_SERVICE_NAME="PLACEHOLDER"

export PROCESS_ID="PLACEHOLDER"

export MYSQL_USER="PLACEHOLDER"

export NAMESPACE="PLACEHOLDER"

export MYSQL_PASSWORD="PLACEHOLDER"
```

## Debug

### Next Step
```shell
shell

# List all pods in the current namespace

kubectl get pods
```

### Check the status of the pod in question
```shell
kubectl describe pod ${POD_NAME}
```

### Check the logs of the MySQL container in the pod
```shell
kubectl logs ${POD_NAME} ${MYSQL_CONTAINER_NAME}
```

### Check the status of the MySQL service
```shell
kubectl get svc ${MYSQL_SERVICE_NAME}
```

### Check if the MySQL database is locked
```shell
kubectl exec ${POD_NAME} -c ${MYSQL_CONTAINER_NAME} -- mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SHOW OPEN TABLES WHERE In_use > 0;"
```

### Inside the container, connect to the MySQL database
```shell
mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD}
```

### Inside the MySQL prompt, show the process list
```shell
SHOW PROCESSLIST;
```

### Inside the MySQL prompt, show the locked tables
```shell
SHOW OPEN TABLES WHERE In_use > 0;
```

## Repair

### Inside the MySQL prompt, kill a locked process
```shell
KILL ${PROCESS_ID};
```

### If the locks cannot be released, try restarting the MySQL service or the entire pod to clear all locks.
```shell
bash

#!/bin/bash



# Set variables

NAMESPACE=${NAMESPACE}

POD_NAME=${POD_NAME}

MYSQL_SERVICE=${MYSQL_SERVICE_NAME}



# Check for active locks

if kubectl exec -n $NAMESPACE $POD_NAME -- mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SHOW OPEN TABLES WHERE In_use > 0" | grep -q "In_use"; then

  # Kill processes causing locks

  kubectl exec -n $NAMESPACE $POD_NAME -- mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SHOW PROCESSLIST" | grep -v "Sleep" | awk '{print "KILL "$1";"}' | kubectl exec -n $NAMESPACE $POD_NAME -- mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD}



  # If locks persist, restart MySQL service or entire pod

  kubectl rollout restart deployment $MYSQL_SERVICE -n $NAMESPACE

  # OR

  kubectl delete pod $POD_NAME -n $NAMESPACE

fi


```