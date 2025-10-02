# Compute module variables

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zone" {
  description = "GCP zone"
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

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

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