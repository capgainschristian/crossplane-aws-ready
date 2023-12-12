Boilerplate code to manage AWS resources using ArgoCD and Crossplane.

This repo will get you up and running with an EC2 instance that you can ssh into.

PREREQUISITES

1) You will need awscli, helm, and minikube installed.

2) You will need to add your AWS credentials as a file:

```
[default]
aws_access_key_id = <your_aws_access_key>
aws_secret_access_key = <your_aws_secret_key>
```
Save the file as aws-credentials.txt and then run the following:

```
kubectl create ns crossplane-system

kubectl create secret \
generic aws-secret \
-n crossplane-system \
--from-file=creds=./aws-credentials.txt
```

3) You will need to create an EC2 key-pair called crossplane_key:

```
aws ec2 create-key-pair --key-name crossplane_key --query 'KeyMaterial' --output text > MyKeyPair.pem
chmod 400 MyKeyPair.pem
```

INSTALLATION

1) Verify that the crossplane-system namespace has the aws-secret:

```
kubectl get secret aws-secret -n crossplane-system
```

2) Run the ./setup script.

3) Wait for your EC2 instance to show up on AWS, then try to ssh into it using your MyKeyPair.pem key.

![image](https://github.com/capgainschristian/crossplane-aws-ready/assets/63564473/200e4c4a-be57-46d1-9f9f-348a904cd8b8)
ArgoCD dashboard with AWS application.
![image](https://github.com/capgainschristian/crossplane-aws-ready/assets/63564473/013ec9de-1f52-4cf8-9d4e-83f9efec241b)
AWS application showing all of the AWS resources currently deployed.
![image](https://github.com/capgainschristian/crossplane-aws-ready/assets/63564473/3f26acdb-8bb6-49b6-bf94-3f53ab6da97b)
EC2 instance information
![image](https://github.com/capgainschristian/crossplane-aws-ready/assets/63564473/cdbe0642-7810-4351-8602-075c6eaa7d91)
SSH into the created EC2 instance with secret key.
