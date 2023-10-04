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