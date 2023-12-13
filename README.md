Boilerplate code to manage AWS resources using ArgoCD and Crossplane.

This repo will get you up and running with an EC2 instance that you can ssh into.

PREREQUISITES

1) Install awscli, helm, and minikube.

2) Save your AWS credentials to a file called aws-credentials.txt:

```
[default]
aws_access_key_id = <your_aws_access_key>
aws_secret_access_key = <your_aws_secret_key>
```

Then run the following (make sure ```--from-file=creds=``` is pointing to the location of the file you created above) to create the secret for your AWS provider:

```
kubectl create ns crossplane-system

kubectl create secret \
generic aws-secret \
-n crossplane-system \
--from-file=creds=./aws-credentials.txt
```

3) Create an EC2 key-pair called crossplane_key. It has to be called crossplane_key because that's what the EC2 Custom Resource Definition (CRD) will be looking for:

```
aws ec2 create-key-pair --key-name crossplane_key --query 'KeyMaterial' --output text > MyKeyPair.pem
chmod 400 MyKeyPair.pem
```

4) Create the secret ```private-repo-creds``` for your ArgoCD instance to use. Make sure to replace the values under StringData with your Github account information:

```
kubectl create ns argocd

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
```

INSTALLATION

1) Verify that you have the required secrets created:

```
kubectl get secret aws-secret -n crossplane-system
kubectl get secret private-repo-creds -n argocd
```

2) Run the ./setup script. Alternatively, if you want to skip ArgoCD and just run Crossplane, do the following:

```
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm install crossplane --namespace crossplane-system crossplane-stable/crossplane --wait

kubectl apply -f crossplane/aws/aws.yaml
kubectl wait provider/provider-aws --for=condition=Healthy --timeout=240s
kubectl apply -f crossplane/aws/provider_config.yaml

kubectl apply -f crossplane/aws/resources/.
```

3) Wait for your EC2 instance to show up on AWS, then try to ssh into it using your MyKeyPair.pem key.




![image](https://github.com/capgainschristian/crossplane-aws-ready/assets/63564473/200e4c4a-be57-46d1-9f9f-348a904cd8b8)
ArgoCD dashboard with AWS application.

![image](https://github.com/capgainschristian/crossplane-aws-ready/assets/63564473/013ec9de-1f52-4cf8-9d4e-83f9efec241b)
AWS application showing all of the AWS resources currently deployed.

DELETE

To delete all of the resources, run the following command:

```
helm template charts/apps/ | kubectl delete -f -
```
