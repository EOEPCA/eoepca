#!/bin/bash
RES_ID=""
while getopts ":r:" opt; do
  case ${opt} in
    r ) RES_ID=$OPTARG
      ;;
    \? )
        echo "Invalid option: -$OPTARG" 1>&2
        exit 1
      ;;
    esac
done
RES_ID=$(echo $RES_ID |  tr -d '"' | tr -d '\')
a=$(kubectl get pods | grep pdp)
echo $RES_ID
for value in $a
do 
    v=$(kubectl exec $value -c pdp-engine -- management_tools list -r $RES_ID)
    break
done
for u in $v;
do
    if echo "$u" | grep -q "ObjectId"; then
        echo $u| cut -d"'" -f 2 | tr -d "\n\r" > ./02__Processing/01__ADES/P_ID.txt
        break
    fi

done
