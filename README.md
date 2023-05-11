## Configuring Two EC2 instances in Two Regions using Terraform on LocalStack ##
This guide will walk you through the steps to configure two EC2 instances in two different AWS regions using Terraform and running it on LocalStack.

## Prerequisites
LocalStack setup and running on your machine.
Terraform installed on your machine.
AWS CLI installed and configured on your machine 

## Step 1: Review of Main.tf file

## Step 2: Run Terraform Commands
Now, go to the terminal and navigate to the directory where you have saved the main.tf file. Run the following commands:
```
terraform init
terraform plan
terraform apply --auto-approve
```
## Step3: Review the outputs in Localstack 
Now , Run the command to check if 2 instances are created in 2 different AWS regions 
## For Region US-EAST-1
```
aws --endpoint-url=http://localhost:4566 ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,InstanceType,PublicIpAddress,Tags[?Key==`Name`]| [0].Value]' --output table --region us-east-1 
```

## For Region US-EAST-2
```
aws --endpoint-url=http://localhost:4566 ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,InstanceType,PublicIpAddress,Tags[?Key==`Name`]| [0].Value]' --output table --region us-east-2
```
