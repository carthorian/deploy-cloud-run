SHELL=bash
SERVICE_NAME=$(cat terraform.tfvars | grep deployment_name | cut -d "=" -f 2 | cut -d '"' -f 2)
PROJECT_NAME=$(cat terraform.tfvars | grep "project " | cut -d "=" -f 2 | cut -d '"' -f 2)

VERSION := test

build:
		terraform init
		terraform plan
		terraform apply -auto-approve

test:
		echo "no tests"
		terraform init
		terraform plan
		terraform apply -auto-approve
		echo "Waiting 10mins for the Gcp Loadbalancer become healty.""
		sleep 600
		export APP_NAME=$(cat terraform.tfvars | grep deployment_name | cut -d "=" -f 2 | cut -d '"' -f 2)
		export PROJECT_NAME=$(cat terraform.tfvars | grep "project " | cut -d "=" -f 2 | cut -d '"' -f 2)
		export IP_ADDRESS=$(gcloud compute addresses list  --filter="name=$APP_NAME-loadbalancer-ip" --global --format="value(ADDRESS)")
		curl -v -k -H "Host: cloudruntest.example.com" https://$IP_ADDRESS

remove:
		terraform plan destroy
		terraform destroy 
