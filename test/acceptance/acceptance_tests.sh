#!/usr/bin/env bash

source $HOME/.local/robot/bin/activate
pip install -r ./requirements.txt
login_service="./UserManagement/LoginService"
cd "$login_service"
python3 registerClient.py
robot UMA_Flow.robot
cd -
sleep 2
pwd
cd ./Processing/ADES
robot WPS.robot
robot API_PROC.robot
deactivate
cd -

