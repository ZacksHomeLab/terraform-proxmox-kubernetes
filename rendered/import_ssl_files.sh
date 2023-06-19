#!/bin/bash

ssl_data=$1

if [ $user_id -ne 0 ]; then
    echo "Need to run with sudo privilege"
    exit 1
fi

json_data=$(echo $ssl_data | tr -d '\n')

for i in $(echo $json_data | jq -r 'keys[]'); do
  content=$(echo "$json_data" | jq -r ".[\"$i\"].content")
  destination=$(echo "$json_data" | jq -r ".[\"$i\"].destination")
  directory=$(dirname $destination)

  if [ ! -d $directory ]; then
    mkdir --parents $directory
  fi

  echo $content | tee $destination &>1
done
