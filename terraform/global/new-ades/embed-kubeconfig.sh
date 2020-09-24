#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

kubectl config set-cluster minikube --certificate-authority=$HOME/.minikube/ca.crt --embed-certs
kubectl config set-credentials minikube --client-certificate=$HOME/.minikube/profiles/minikube/client.crt --embed-certs
kubectl config set-credentials minikube --client-key=$HOME/.minikube/profiles/minikube/client.key --embed-certs
kubectl config view --raw
