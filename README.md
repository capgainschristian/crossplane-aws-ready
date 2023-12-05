Boilerplate code to manage AWS resources using ArgoCD and Crossplane.

This repo will get you up and running with an EC2 instance that you can ssh into.

PREREQUISITES

1) You will need awscli and minikube installed.

2) You will need to generate an AWS key-pair file:

[default]
aws_access_key_id = <your_aws_access_key>
aws_secret_access_key = <your_aws_secret_key>

Save the file as aws-credentials.txt and then run the following:

kubectl create secret \
generic aws-secret \
-n crossplane-system \
--from-file=creds=./aws-credentials.txt

3) You will need to create an EC2 key-pair called crossplane_key:

aws ec2 create-key-pair --key-name crossplane_key --query 'KeyMaterial' --output text > MyKeyPair.pem
chmod 400 MyKeyPair.pem

4) Run the ./setup script.

5) Once everything is up and running, try to ssh into your ec2 instance: ssh -i MyKeyPair ec2-user@<dns/publicIP>
