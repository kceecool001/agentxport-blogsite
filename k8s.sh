#!/bin/bash
aws eks update-kubeconfig \
  --region eu-central-1 \
  --name agentxport-eks

kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secret.yaml


kubectl apply -f k8s/storage/
kubectl apply -f k8s/database/

kubectl apply -f k8s/backend/
kubectl apply -f k8s/frontend/
kubectl apply -f k8s/networkpolicy/
kubectl apply -f k8s/networkpolicy/frontend-policy.yaml


