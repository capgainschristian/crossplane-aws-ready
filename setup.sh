#!/bin/bash

minikube start --cpus=4 --memory=16GB

kubectl create ns argocd

# There is a cleaner way of doing this by either using kustomize or Helm
sops -d charts/credentials/argocd-repo-creds.txt > env_vars.txt && source env_vars.txt
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-creds
  namespace: argocd
  annotations:
    managed-by: argocd.argoproj.io
  labels:
    argocd.argoproj.io/secret-type: repository
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
kubectl delete secret -l owner=helm,name=argo-cd -A

kubectl create namespace crossplane-system
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm install crossplane --namespace crossplane-system crossplane-stable/crossplane --wait

sops -d crossplane/aws/credentials/aws-credentials.txt > delete_me.txt
kubectl create secret generic aws-secret -n crossplane-system --from-file=creds=./delete_me.txt
rm delete_me.txt

kubectl apply -f crossplane/aws/aws.yaml
kubectl wait provider/provider-aws --for=condition=Healthy --timeout=240s
kubectl apply -f crossplane/aws/provider_config.yaml

helm template charts/apps/ | kubectl apply -f -

echo "To login to argoCD web GUI, please use the following password.."
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
#kubectl port-forward svc/argocd-server 8080:443 -n argocd
