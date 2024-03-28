#!/bin/bash -x
eval "$(jq -r '@sh "NAME=\(.resource_name) OPTION=\(.resource_option) TYPE=\(.resource_type) VALUE=\(.resource_value)"')"
aws $NAME $OPTION $TYPE $VALUE  > /dev/null  2>&1
if [[ $? > 0 ]]
then 
 ##### If service Not Exists then return value  1 so that this value can be used later using count for creating resource
  RESULT=0
  CHECK=1
else 
 ##### If Service Exists then return value  0 so that this value can be use in count for not to skip creating resource
  RESULT=1
  CHECK=0
fi
jq --arg result "$RESULT" --arg check "$CHECK" -n '{"count": $result, "check": $check}'
