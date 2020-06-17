#!/usr/bin/env bash

my_special_place="$HOME/eoepca/test/acceptance/UserManagement/LoginService"
cd "$my_special_place"
virtualenv -p python3 env
source env/bin/activate
pip install -r ../../../../requirements.txt
python3 registerClient.py
deactivate
source $HOME/.local/robot/bin/activate
robot UMA_Flow.robot
deactivate
rm -rf ./env/
cd -
sleep 2
pwd
cd ./Processing/ADES
source $HOME/.local/robot/bin/activate
robot WPS.robot
robot API_PROC.robot
deactivate
cd -

