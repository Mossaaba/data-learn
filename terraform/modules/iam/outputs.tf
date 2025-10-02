# IAM module outputs

# Main service account outputs
output "service_account_email" {
  description = "Email of the main service account"
  value       = google_service_account.main_service_account.email
}

output "service_account_key" {
  description = "Base64 encoded service account key"
  value       = google_service_account_key.main_service_account_key.private_key
  sensitive   = true
}

# Kafka service account outputs
output "kafka_service_account_email" {
  description = "Email of the Kafka service account"
  value       = google_service_account.kafka_service_account.email
}

# Spark service account outputs
output "spark_service_account_email" {
  description = "Email of the Spark service account"
  value       = google_service_account.spark_service_account.email
}

# Airflow service account outputs
output "airflow_service_account_email" {
  description = "Email of the Airflow service account"
  value       = google_service_account.airflow_service_account.email
}

# Custom role output
output "custom_role_name" {
  description = "Name of the custom data pipeline role"
  value       = google_project_iam_custom_role.data_pipeline_role.name
}