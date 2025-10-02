# Variables for GCP data pipeline infrastructure

# ===== GENERAL CONFIGURATION =====
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# ===== COMPUTE CONFIGURATION =====
variable "kafka_machine_type" {
  description = "Machine type for Kafka VM"
  type        = string
  default     = "e2-standard-2"
}

variable "spark_machine_type" {
  description = "Machine type for Spark VM"
  type        = string
  default     = "e2-standard-4"
}

variable "airflow_machine_type" {
  description = "Machine type for Airflow VM"
  type        = string
  default     = "e2-standard-2"
}

# ===== DATA WAREHOUSE CONFIGURATION =====
variable "data_warehouse_type" {
  description = "Type of data warehouse (bigquery, redshift, snowflake)"
  type        = string
  default     = "bigquery"
  validation {
    condition     = contains(["bigquery", "redshift", "snowflake"], var.data_warehouse_type)
    error_message = "Data warehouse type must be one of: bigquery, redshift, snowflake."
  }
}

# BigQuery variables
variable "bigquery_dataset_id" {
  description = "BigQuery dataset ID"
  type        = string
  default     = "data_pipeline"
}

# AWS/Redshift variables
variable "aws_region" {
  description = "AWS region for Redshift"
  type        = string
  default     = "us-east-1"
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "redshift_cluster_id" {
  description = "Redshift cluster identifier"
  type        = string
  default     = "data-pipeline-cluster"
}

variable "redshift_database_name" {
  description = "Redshift database name"
  type        = string
  default     = "data_pipeline"
}

variable "redshift_master_username" {
  description = "Redshift master username"
  type        = string
  default     = "admin"
}

variable "redshift_master_password" {
  description = "Redshift master password"
  type        = string
  default     = ""
  sensitive   = true
}

# Snowflake variables
variable "snowflake_account" {
  description = "Snowflake account identifier"
  type        = string
  default     = ""
}

variable "snowflake_username" {
  description = "Snowflake username"
  type        = string
  default     = ""
}

variable "snowflake_password" {
  description = "Snowflake password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "snowflake_database" {
  description = "Snowflake database name"
  type        = string
  default     = "DATA_PIPELINE"
}

variable "snowflake_warehouse" {
  description = "Snowflake warehouse name"
  type        = string
  default     = "COMPUTE_WH"
}

variable "snowflake_schema" {
  description = "Snowflake schema name"
  type        = string
  default     = "PUBLIC"
}

# ===== MONITORING CONFIGURATION =====
variable "billing_account" {
  description = "GCP billing account ID"
  type        = string
}

variable "budget_amount" {
  description = "Budget amount in USD"
  type        = number
  default     = 100
}

variable "alert_email" {
  description = "Email address for budget alerts"
  type        = string
}