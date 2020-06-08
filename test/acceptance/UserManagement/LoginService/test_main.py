#!/usr/bin/env python3
import subprocess
import os, sys
from os import path
import socket
import time
import json

#Request a resource without access_token
#Returns a ticket to user for the token retrieval
def get_ticket(config):
    ip=config['hostname']+ ':32125'
    if not path.exists('1'):
        f = open("1", "w+")
        process=subprocess.Popen(['./CLI/request-resource.sh', '-s', ip,'-r','/pep/ADES'], stderr = f)
        time.sleep(5)
    f.flush()
    ticket = ''
    with open('1','r+') as m:
        for i in m:
            a =''.join(i)
            if 'ticket' in a:
                ticket = a[a.find('ticket')+7:-1]
    f.close()
    return ticket


#Request authentication, a user must be specified, aswell as the client
#Returns an id_token to use for the acces_token retrieval 
def get_id_token(config):
    if not path.exists('2'):
        r = open("2", "w+")
        pro=subprocess.Popen(['./CLI/authenticate-user.sh', '-S', '-a', config['hostname'],'-i',config['client_id'],'-p',config['client_secret'],'-s','openid', '-u', config['username'], '-w', config['password'], '-r', 'none'], stdout = r)
        time.sleep(2)
    r.flush()
    r.close()
    id_token = ''
    with open('2','r+') as m:
        for i in m:
            a =''.join(i)
            if 'id_token' in a:
                
                id_token = a[a.find('id_token')+11:a.find('token_type')-3]
    return id_token

#Generates an acces token for the requested resource
def get_acces_token(config, ticket, id_token):
    if not path.exists('3'):
        r = open("3", "w+")
        pro=subprocess.Popen(['./CLI/get-rpt.sh', '-S', '-a', config['hostname'],'-t',ticket,'-i',config['client_id'],'-p',config['client_secret'],'-s','openid','-c', id_token], stdout = r)
        time.sleep(2)
    r.flush()
    r.close()
    access_token = ''
    with open('3','r+') as m:
        for i in m:
            a =''.join(i)
            if 'access_token' in a:
                access_token = a[a.find('access_token')+15:a.find('token_type')-3]
    return access_token


def update_config_token(access_token):
    os.system('sed -i "/_TOKEN}=/c\${RPT_TOKEN}=  '+access_token+'" ./../../Processing/ADES/ADES.resource')
    
#Retreives the resource specifying the acces_token
def get_resource(access_token):
    
    ip=subprocess.check_output(['hostname','-i']).strip().decode()+':5566'
    o = open("4", "w+")
    process=subprocess.Popen(['./CLI/request-resource.sh', '-s', ip,'-r','/pep/ADES', '-t', access_token], stdout = o)
    time.sleep(5)
    o.close()

    with open('4','r+') as f:
        for i in f:
            joinedStr =''.join(i)
            if 'TestPEP' in joinedStr:
                return joinedStr
        
            

def main():
    with open('test_settings.json', 'r') as config:
        config=config.read()
    config = json.loads(config)

    

    if not path.exists('1'):
        ticket=get_ticket(config)
        print('ticket: ')
        print(ticket)
        id_token=get_id_token(config)
        print('id_token: ')
        print(id_token)
        valid=get_acces_token(config, ticket, id_token)
        print('acces_token: ')
        print(valid)
        if valid:
            update_config_token(valid)

main()





