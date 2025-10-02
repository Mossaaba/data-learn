# Data Warehouse module variables

# Common variables
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "data_warehouse_type" {
  description = "Type of data warehouse (bigquery, redshift, snowflake)"
  type        = string
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