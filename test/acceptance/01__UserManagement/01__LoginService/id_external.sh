#!/usr/bin/env bash

curl -k -X POST  "https://um.nextgeoss.eu/oxauth/restv1/token"   -H 'content-type: application/x-www-form-urlencoded'   -d 'client_id=%40!27B7.E085.07A1.6DE7!0001!F5E4.0B8E!0008!B94A.73C8.5123.B34F&client_secret=defaultclientsecret&grant_type=password&username=herc&password=hercherc&redirect_uri=https%3A%2F%2Fwww.getpostman.com%2Foauth2%2Fcallback&scope=openid%20user_name%20profile' > ./01__UserManagement/01__LoginService/external_id.txt
