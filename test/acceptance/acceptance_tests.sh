#!/bin/bash

cd ./UserManagement/LoginService
python3 test_main.py
cd -
cd ./Processing/ADES
source $HOME/.local/robot/bin/activate
robot WPS.robot
robot API_PROC.robot
deactivate
cd -

