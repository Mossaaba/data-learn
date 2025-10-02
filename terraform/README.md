# GCP Infrastructure with Terraform

This Terraform configuration creates a complete data pipeline infrastructure on Google Cloud Platform with Kafka, Spark, and Airflow VMs, plus data warehouse abstraction.

## Architecture Overview

- **VPC Network**: Custom network with firewall rules
- **Compute Instances**: 3 VMs (Kafka, Spark, Airflow)
- **Data Warehouse**: Abstracted (BigQuery/Redshift/Snowflake)
- **IAM**: Service accounts with proper permissions
- **Monitoring**: Budget alerts and notifications

## Prerequisites

1. **Google Cloud SDK**: Install and configure
```bash
# Install gcloud CLI
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Login and set project
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
gcloud auth application-default login
```

2. **Terraform**: Install Terraform >= 1.0
```bash
# macOS
brew install terraform

# Verify installation
terraform version
```

3. **Enable Required APIs**:
```bash
gcloud services enable compute.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable bigquery.googleapis.com
```

## Setup Instructions

### 1. Configure Variables

Copy and customize the variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:
```hcl
project_id = "your-gcp-project-id"
region     = "us-central1"
zone       = "us-central1-a"
environment = "dev"
data_warehouse_type = "bigquery"  # or "redshift" or "snowflake"
```

### 2. Initialize and Deploy

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### 3. Connect to VMs

After deployment, connect to your VMs:

```bash
# Get VM external IPs
terraform output vm_external_ips

# SSH to Kafka VM
gcloud compute ssh kafka-vm --zone=us-central1-a

# SSH to Spark VM  
gcloud compute ssh spark-vm --zone=us-central1-a

# SSH to Airflow VM
gcloud compute ssh airflow-vm --zone=us-central1-a
```

### 4. Service Account Keys

Download service account keys for applications:
```bash
# Get service account email
terraform output service_account_email

# Create and download key
gcloud iam service-accounts keys create key.json \
  --iam-account=$(terraform output -raw service_account_email)
```

## Data Warehouse Configuration

### BigQuery (Default)
- Dataset created automatically
- Service account has BigQuery permissions
- Connection string available in outputs

### Redshift
- Requires AWS credentials in variables
- Creates Redshift cluster in AWS
- VPC peering may be needed

### Snowflake
- Requires Snowflake account details
- Creates database and warehouse
- Network policies configured

## Monitoring and Alerts

- Budget alerts configured for cost monitoring
- Email notifications sent to specified address
- Threshold: $100/month (configurable)

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure you have Owner or Editor role
2. **API Not Enabled**: Run the gcloud services enable commands
3. **Quota Exceeded**: Check GCP quotas in console
4. **SSH Issues**: Ensure firewall rules allow SSH (port 22)

### Useful Commands

```bash
# Check Terraform state
terraform state list

# Get specific output
terraform output vm_external_ips

# Refresh state
terraform refresh

# Import existing resource
terraform import google_compute_instance.kafka projects/PROJECT/zones/ZONE/instances/INSTANCE
```

## Security Notes

- Service accounts follow principle of least privilege
- Firewall rules restrict access to necessary ports only
- VM instances use custom service accounts
- Budget alerts prevent unexpected costs

## Next Steps

1. Install Docker and docker-compose on VMs
2. Deploy your applications using the docker-compose.yml
3. Configure data warehouse connections
4. Set up monitoring and logging
5. Implement backup strategies