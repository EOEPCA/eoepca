#!/usr/bin/env bash

source $HOME/.local/robot/bin/activate
pip install -r ./requirements.txt
login_service="./UserManagement/LoginService"
user_profile="./UserManagement/UserProfile"
cd "$login_service"
python3 registerClient.py
robot UMA_Flow.robot
cd -
cd "$user_profile"
robot LoginServiceInteraction.robot
cd -
cd ./Processing/ADES
robot WPS.robot
robot API_PROC.robot
deactivate
cd -

