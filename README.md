# deploy-cloud-run

Terraform template for Google Cloud Run

This terraform template (script) deploy `Hello World` app to GCP via Cloud Run Service.

The script supports multiple features and you can activate/change these features via variables.

Before running the terraform script, you need to create a service account key and put it under the repository main folder.  You can find a sample service account key file named `deploy-sa.json` in this repository.

You need to create a service account and need to give the required permission to this service account. You can find more information in [here](https://cloud.google.com/iam/docs/keys-create-delete)

With default variables, you will deploy the Hello World app to your GCP environment as Cloud Run Service. But the app will accept only internal traffic and external Application loadbalancers. If you want to deploy public, you can configure the variables.

This script also will create a Network Endpoint Group (NEG), Public Ip address, SSL Certificate, Global External Loadbalaner, Backend, and Frontend configurations, Service Accounts, etc.


# Default terraform.tfvars variables:
```hcl
project             = "sample-project"            # Before run the script, you need to update this variable and need to use your project name
location            = "us-central1"               # As default, the script will create resources under the us-central1 region. 
deployment_name     = "hello-app"                 # This will be the service name and will use in all other resource names
ssl_priv_key        = "tls.key"                   # Selfsigned SSL certificate's private key file. It generated for cloudruntest.example.com 
ssl_public_cert     = "tls.crt"                   # Selfsigned SSL certificate's public cert file. It generated for cloudruntest.example.com 
use_selfsigned_cert = true                        # This will use for the create Selfsigned SSL cert or Google Managed SSL cert in your loadbalancer. If you have a domain definition under your GCP project, you can set false and update the deployment_fqdn variable with your domain.
deployment_fqdn     = "cloudruntest.example.com"  # This variable will use for Google Managed SSL certificate.
allow_unauth        = false                       # Authentication type : Allow unauthenticated invocations / Require authentication
is_public_deploy    = false                       # Ingress control. The Cloud Run service will accept traffic from public internet or internal network 
max_scale           = 3                           # Maximum number of instances
min_scale           = 1                           # Minimum number of instances

```

# Diagram
![alt text](https://github.com/carthorian/deploy-cloud-run/blob/main/diagram.jpg?raw=true)

# SSL Certificate
If you want to use Google managed SSL certificates, you need to register your domian to your GCP account. Please check this [link](https://cloud.google.com/domains/docs/register-domain)

If you don't have a registered domain under your GCP account, you can use your signed/self-signed certificates. If you want to use your own FQDN, you can create your self-signed SSL certificate. For this, you need to run the below command on your local and copy "tls.key" and "tls.crt" files to this repository folder. 

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/C=UK/CN=your_app_name.your_domain.com"
```

# Security
This script will create SSL certificate and will configure the loadbalancer to use HTTPS.

Also, if you use `allow_unauth = false` variable, the Cloud Run Service will accept requests with Authorization token. You can net access to Cloud Run service without Authorization token. You will get `Your client does not have permission to get URL from this server.` response from the Cloud Run Service.

The script will create a service account (`${app_deployment_name}-access-sa@${your_project}.iam.gserviceaccount.com`) and this service account will have permission to call your Cloud Run Service.

# Deploy
After updating `deploy-sa.json` file and changing `project` variable in terraform.tfvars file, you can deploy Hello World app to your GCP account as Cloud Run Service. 

```bash
home@user:~/$ terraform init
    Initializing the backend...
    Successfully configured the backend "local"! Terraform will automatically
    use this backend unless the backend configuration changes.
    ...
    ...
    Plan: 16 to add, 0 to change, 0 to destroy.
    Changes to Outputs:
    + Clour_Run_Url         = (known after apply)
    + lb_public_ip_address  = (known after apply)
    + service_account_email = (known after apply)

```

```bash
home@user:~/$ terraform plan
    data.google_client_config.current: Reading...
    data.google_client_config.current: Read complete after 0s [id=projects/"sample-project"/regions/<null>/zones/<null>]
    Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
    ...
    ...
    Plan: 16 to add, 0 to change, 0 to destroy.
    Changes to Outputs:
    + Clour_Run_Url         = (known after apply)
    + lb_public_ip_address  = (known after apply)
    + service_account_email = (known after apply)

```

```bash
home@user:~/$ terraform apply
    data.google_client_config.current: Reading...
    data.google_client_config.current: Read complete after 0s [id=projects/"sample-project"/regions/<null>/zones/<null>]
    ...
    ...
    Do you want to perform these actions?
    Terraform will perform the actions described above.
    Only 'yes' will be accepted to approve.

Enter a value: yes
    google_project_service.svc_cloudres: Creating...
    google_project_service.svc_cloudres: Still creating... [10s elapsed]
    google_project_service.svc_cloudres: Still creating... [20s elapsed]
    ...
    ...
    Apply complete! Resources: 16 added, 0 changed, 0 destroyed.
    Outputs:
    Clour_Run_Url = "https://hello-app-xxxxec2cja-uc.a.run.app"
    lb_public_ip_address = "34.xxx.xxx.111"
    service_account_email = "hello-app-access-sa@vsample-project.iam.gserviceaccount.com"

```

# Testing
After deployed the Cloud Run service, you can test your app by using below steps:

- If you deployed your app with `allow_unauth=false` your need to use an Authorization token in your requests. You can generate an Authorization token by using the service account (`${app_deployment_name}-access-sa@${your_project}.iam.gserviceaccount.com`) 

In the below example, I created a key and downloaded the key (`test-sa.json`) to my local. Then generated an Authorization token by using this service account and called the Cloud Run service. 


The request without an Authorization token got 403 responses.

```bash
home@user:~/$ curl -sw '%{http_code}\n' -k  https://cloudruntest.example.com -o /dev/null
403

```


The request with an Authorization token got 200 responses.

```bash
home@user:~/$ gcloud auth activate-service-account --key-file=test-sa.json
    Activated service account credentials for: [hello-app-access-sa@sample-project.iam.gserviceaccount.com]

home@user:~/$ gcloud auth list
   Credentialed Accounts
    ACTIVE  ACCOUNT
    *       hello-app-access-sa@sample-project.iam.gserviceaccount.com

home@user:~/$ export APPTOKEN=$(gcloud auth print-identity-token)
home@user:~/$ curl -v -k  -H "Authorization: bearer $APPTOKEN" https://cloudruntest.example.com
home@user:~/$ curl -sw '%{http_code}\n' -k  -H "Authorization: bearer $APPTOKEN" https://cloudruntest.example.com -o /dev/null
200

```

# Uninstall
If you want to delete all resource wich create via Terraform, you can use `terraform destroy`command.

```bash
home@user:~/$ terraform destroy
    data.google_client_config.current: Reading...
    google_project_service.svc_cloudres: Refreshing state... [id=sample-project/cloudresourcemanager.googleapis.com]
    data.google_client_config.current: Read complete after 0s [id=projects/"sample-project"/regions/<null>/zones/<null>]
    google_project_service.svc_run: Refreshing state... [id=sample-project/run.googleapis.com]
    ...
    ...
    Do you really want to destroy all resources?
    Terraform will destroy all your managed infrastructure, as shown above.
    There is no undo. Only 'yes' will be accepted to confirm.
Enter a value: yes

    module.load-balancer.google_compute_global_forwarding_rule.lb-forwarding-rule: Destroying... [id=projects/sample-project/global/forwardingRules/hello-app-lb-forwarding-rule]
    module.load-balancer.google_compute_global_forwarding_rule.lb-forwarding-rule: Still destroying... [id=projects/sample-project/global/forwardingRules/hello-app-lb-forwarding-rule, 10s elapsed]
    ...
    ...
    google_project_service.svc_cloudres: Destruction complete after 12s
    Destroy complete! Resources: 16 destroyed.

```

