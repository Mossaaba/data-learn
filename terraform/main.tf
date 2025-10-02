# Main Terraform configuration for GCP data pipeline infrastructure
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.70"
    }
  }
}

# Configure Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Configure AWS Provider (for Redshift option)
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Configure Snowflake Provider (for Snowflake option)
provider "snowflake" {
  account  = var.snowflake_account
  username = var.snowflake_username
  password = var.snowflake_password
}

# Local values for resource naming
locals {
  name_prefix = "${var.environment}-data-pipeline"
  common_tags = {
    Environment = var.environment
    Project     = "data-pipeline"
    ManagedBy   = "terraform"
  }
}

# VPC Network Module
module "network" {
  source = "./modules/network"
  
  project_id   = var.project_id
  region       = var.region
  name_prefix  = local.name_prefix
  environment  = var.environment
}

# Compute Instances Module
module "compute" {
  source = "./modules/compute"
  
  project_id    = var.project_id
  region        = var.region
  zone          = var.zone
  name_prefix   = local.name_prefix
  environment   = var.environment
  network_name  = module.network.network_name
  subnet_name   = module.network.subnet_name
  
  # VM configurations
  kafka_machine_type   = var.kafka_machine_type
  spark_machine_type   = var.spark_machine_type
  airflow_machine_type = var.airflow_machine_type
  
  depends_on = [module.network]
}

# IAM Module
module "iam" {
  source = "./modules/iam"
  
  project_id  = var.project_id
  name_prefix = local.name_prefix
  environment = var.environment
}

# Data Warehouse Module (abstracted)
module "data_warehouse" {
  source = "./modules/data_warehouse"
  
  # Common variables
  project_id          = var.project_id
  region              = var.region
  name_prefix         = local.name_prefix
  environment         = var.environment
  data_warehouse_type = var.data_warehouse_type
  
  # BigQuery specific
  bigquery_dataset_id = var.bigquery_dataset_id
  
  # Redshift specific
  aws_region              = var.aws_region
  redshift_cluster_id     = var.redshift_cluster_id
  redshift_database_name  = var.redshift_database_name
  redshift_master_username = var.redshift_master_username
  redshift_master_password = var.redshift_master_password
  
  # Snowflake specific
  snowflake_account   = var.snowflake_account
  snowflake_database  = var.snowflake_database
  snowflake_warehouse = var.snowflake_warehouse
  snowflake_schema    = var.snowflake_schema
}

# Budget and Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"
  
  project_id           = var.project_id
  billing_account      = var.billing_account
  budget_amount        = var.budget_amount
  alert_email          = var.alert_email
  name_prefix          = local.name_prefix
  environment          = var.environment
}