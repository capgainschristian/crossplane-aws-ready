#!/bin/bash

# Start minikube
minikube start --cpus=4 --memory=16GB

# Create a default VPC if you don't have one already
aws ec2 create-default-vpc

# Setup ArgoCD
kubectl create ns argocd
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml -n argocd && \
#kubectl wait --for=condition=ready pod $(kubectl get pods -n argocd | awk '{if ($1 ~ "argocd-server-") print $1}') -n argocd --timeout=30s

# Setup Crossplane
kubectl create namespace crossplane-system
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm install crossplane --namespace crossplane-system crossplane-stable/crossplane --wait

# Create AWS creds secret for crossplane
sops -d crossplane/aws/credentials/aws-credentials.txt > delete_me.txt
kubectl create secret generic aws-secret -n crossplane-system --from-file=creds=./delete_me.txt
rm delete_me.txt

# Generate AWS providers
kubectl apply -f crossplane/aws/aws.yaml
kubectl wait provider/provider-aws --for=condition=Healthy --timeout=240s
kubectl apply -f crossplane/aws/provider_config.yaml

# App of Apps install
helm template charts/root-app/ | kubectl apply -f -

# ArgoCD password
echo "To login to argoCD web GUI, please use the following password.."
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
#kubectl port-forward svc/argo-cd-argocd-server 8080:443

