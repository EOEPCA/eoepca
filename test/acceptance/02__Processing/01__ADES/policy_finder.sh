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
a=$(kubectl get pods | grep pdp)
for value in $a
do 
    v=$(kubectl exec $value -c pdp-engine -- management_tools list -r $RES_ID)
    break
done

for u in $v;
do
    if [[ $u == *"ObjectId"* ]]; then
        echo $u| cut -d"'" -f 2 > ./P_ID.txt

        break
    fi
done

wc -l < P_ID.txt | tr -d '\n'
