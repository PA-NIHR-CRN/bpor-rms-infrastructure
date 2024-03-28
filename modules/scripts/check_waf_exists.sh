#!/bin/bash -x
eval "$(jq -r '@sh "NAME=\(.resource_name) OPTION=\(.resource_option) TYPE=\(.resource_type) VALUE=\(.resource_value) ENV=\(.resource_env)"')"
STATUS=$(aws $NAME $OPTION $TYPE |jq -r '.WebACLs[].Name' |grep -w $VALUE|wc -l)
CMD=$(echo "aws $NAME $OPTION $TYPE |jq -r '.WebACLs[].Name' |grep -w $VALUE|wc -l")

if [[ $STATUS -gt 0 ]]
then 
 ##### If service Exists then return value 
  if [[ $ENV == "qa" ]] || [[ $ENV == "uat" ]]
  then
    RESULT=false
  else
    RESULT=true
  fi
  ARN=$(aws $NAME $OPTION $TYPE|jq -r --arg value "$VALUE" '.WebACLs[]|select(.Name==$value)|.ARN')
  ARN_EXISTS=true
else 
 ##### If Service Not Exists then return value 
  RESULT=true
  ARN_EXISTS=false
fi
jq --arg arn_exists "$ARN_EXISTS" --arg arn "$ARN" --arg cmd "$CMD" --arg result "$RESULT" --arg name "$NAME" --arg option "$OPTION" --arg type "$TYPE" --arg value "$VALUE" -n '{"result": $result, "name": $name, "option": $option, "type": $type, "value": $value, "cmd": $cmd, "arn": $arn, "arn_exists": $arn_exists }'
