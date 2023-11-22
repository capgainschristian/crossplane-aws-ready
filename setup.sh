#!/bin/bash

# Start minikube
minikube start --cpus=4 --memory=16GB

# Setup ArgoCD
helm repo add argo-cd https://argoproj.github.io/argo-helm
helm dep update charts/argo-cd/
helm install argo-cd charts/argo-cd/ --wait

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
kubectl apply -f crossplane/aws/s3.yaml
kubectl wait provider/provider-aws-s3 --for=condition=Healthy --timeout=30s
kubectl apply -f crossplane/aws/provider_config.yaml

# App of Apps install
helm template charts/root-app/ | kubectl apply -f -

# ArgoCD password
echo "To login to argoCD web GUI, please use the following password.."
kubectl get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
#kubectl port-forward svc/argo-cd-argocd-server 8080:443

