# Compute module outputs

# Kafka VM outputs
output "kafka_vm_name" {
  description = "Name of the Kafka VM"
  value       = google_compute_instance.kafka_vm.name
}

output "kafka_external_ip" {
  description = "External IP of the Kafka VM"
  value       = google_compute_instance.kafka_vm.network_interface[0].access_config[0].nat_ip
}

output "kafka_internal_ip" {
  description = "Internal IP of the Kafka VM"
  value       = google_compute_instance.kafka_vm.network_interface[0].network_ip
}

# Spark VM outputs
output "spark_vm_name" {
  description = "Name of the Spark VM"
  value       = google_compute_instance.spark_vm.name
}

output "spark_external_ip" {
  description = "External IP of the Spark VM"
  value       = google_compute_instance.spark_vm.network_interface[0].access_config[0].nat_ip
}

output "spark_internal_ip" {
  description = "Internal IP of the Spark VM"
  value       = google_compute_instance.spark_vm.network_interface[0].network_ip
}

# Airflow VM outputs
output "airflow_vm_name" {
  description = "Name of the Airflow VM"
  value       = google_compute_instance.airflow_vm.name
}

output "airflow_external_ip" {
  description = "External IP of the Airflow VM"
  value       = google_compute_instance.airflow_vm.network_interface[0].access_config[0].nat_ip
}

output "airflow_internal_ip" {
  description = "Internal IP of the Airflow VM"
  value       = google_compute_instance.airflow_vm.network_interface[0].network_ip
}

# Service account outputs
output "vm_service_account_email" {
  description = "Email of the VM service account"
  value       = google_service_account.vm_service_account.email
}