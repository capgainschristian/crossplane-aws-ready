#!/bin/bash

# Start minikube
minikube start --cpus=4 --memory=16GB

# Add argocd secret

kubectl create ns argocd
sops -d charts/credentials/argocd-repo-creds.txt > env_vars.txt && source env_vars.txt
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-creds
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repo-creds
stringData:
  type: ${TYPE}
  url: ${URL}
  password: ${PASSWORD}
  username: ${USERNAME}
EOF
rm env_vars.txt

helm repo add argo-cd https://argoproj.github.io/argo-helm
helm dep update charts/argo-cd/
helm install argo-cd charts/argo-cd/ --namespace argocd
#kubectl delete secret -l owner=helm,name=argo-cd

#kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml -n argocd
#kubectl wait --for=condition=ready pod $(kubectl get pods -n argocd | awk '{if ($1 ~ "argocd-server-") print $1}') -n argocd --timeout=30s

