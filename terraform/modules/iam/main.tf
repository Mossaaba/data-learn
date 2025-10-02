# IAM module - Service accounts and permissions

# Main service account for applications
resource "google_service_account" "main_service_account" {
  account_id   = "${var.name_prefix}-main-sa"
  display_name = "Main Service Account for ${var.environment} Data Pipeline"
  description  = "Service account for data pipeline applications and services"
}

# Service account key for applications
resource "google_service_account_key" "main_service_account_key" {
  service_account_id = google_service_account.main_service_account.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

# IAM roles for the main service account
resource "google_project_iam_member" "main_service_account_roles" {
  for_each = toset([
    "roles/bigquery.admin",           # BigQuery access
    "roles/storage.admin",            # Cloud Storage access
    "roles/compute.viewer",           # Compute Engine read access
    "roles/logging.logWriter",        # Cloud Logging
    "roles/monitoring.metricWriter",  # Cloud Monitoring
    "roles/pubsub.admin",            # Pub/Sub for messaging
    "roles/dataflow.admin",          # Dataflow for batch processing
    "roles/cloudsql.client"          # Cloud SQL access if needed
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.main_service_account.email}"
}

# Custom IAM role for specific data pipeline permissions
resource "google_project_iam_custom_role" "data_pipeline_role" {
  role_id     = "${replace(var.name_prefix, "-", "_")}_data_pipeline_role"
  title       = "Data Pipeline Custom Role"
  description = "Custom role for data pipeline operations"
  
  permissions = [
    "bigquery.datasets.create",
    "bigquery.datasets.get",
    "bigquery.tables.create",
    "bigquery.tables.get",
    "bigquery.tables.getData",
    "bigquery.tables.updateData",
    "storage.buckets.create",
    "storage.buckets.get",
    "storage.objects.create",
    "storage.objects.get",
    "storage.objects.delete",
    "compute.instances.get",
    "compute.instances.list"
  ]
}

# Assign custom role to main service account
resource "google_project_iam_member" "main_service_account_custom_role" {
  project = var.project_id
  role    = google_project_iam_custom_role.data_pipeline_role.name
  member  = "serviceAccount:${google_service_account.main_service_account.email}"
}

# Service account for Kafka operations
resource "google_service_account" "kafka_service_account" {
  account_id   = "${var.name_prefix}-kafka-sa"
  display_name = "Kafka Service Account for ${var.environment}"
  description  = "Service account specifically for Kafka operations"
}

# Kafka service account permissions
resource "google_project_iam_member" "kafka_service_account_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/pubsub.admin"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.kafka_service_account.email}"
}

# Service account for Spark operations
resource "google_service_account" "spark_service_account" {
  account_id   = "${var.name_prefix}-spark-sa"
  display_name = "Spark Service Account for ${var.environment}"
  description  = "Service account specifically for Spark operations"
}

# Spark service account permissions
resource "google_project_iam_member" "spark_service_account_roles" {
  for_each = toset([
    "roles/bigquery.dataEditor",
    "roles/storage.admin",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/dataflow.worker"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.spark_service_account.email}"
}

# Service account for Airflow operations
resource "google_service_account" "airflow_service_account" {
  account_id   = "${var.name_prefix}-airflow-sa"
  display_name = "Airflow Service Account for ${var.environment}"
  description  = "Service account specifically for Airflow operations"
}

# Airflow service account permissions
resource "google_project_iam_member" "airflow_service_account_roles" {
  for_each = toset([
    "roles/bigquery.admin",
    "roles/storage.admin",
    "roles/compute.instanceAdmin.v1",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/dataflow.admin",
    "roles/pubsub.admin"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.airflow_service_account.email}"
}