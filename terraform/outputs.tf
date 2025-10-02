# Outputs for GCP data pipeline infrastructure

# ===== NETWORK OUTPUTS =====
output "network_name" {
  description = "Name of the VPC network"
  value       = module.network.network_name
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = module.network.subnet_name
}

# ===== COMPUTE OUTPUTS =====
output "vm_external_ips" {
  description = "External IP addresses of VMs"
  value = {
    kafka   = module.compute.kafka_external_ip
    spark   = module.compute.spark_external_ip
    airflow = module.compute.airflow_external_ip
  }
}

output "vm_internal_ips" {
  description = "Internal IP addresses of VMs"
  value = {
    kafka   = module.compute.kafka_internal_ip
    spark   = module.compute.spark_internal_ip
    airflow = module.compute.airflow_internal_ip
  }
}

output "vm_names" {
  description = "Names of the VM instances"
  value = {
    kafka   = module.compute.kafka_vm_name
    spark   = module.compute.spark_vm_name
    airflow = module.compute.airflow_vm_name
  }
}

# ===== IAM OUTPUTS =====
output "service_account_email" {
  description = "Email of the service account"
  value       = module.iam.service_account_email
}

output "service_account_key" {
  description = "Service account key (base64 encoded)"
  value       = module.iam.service_account_key
  sensitive   = true
}

# ===== DATA WAREHOUSE OUTPUTS =====
output "data_warehouse_connection" {
  description = "Data warehouse connection information"
  value       = module.data_warehouse.connection_info
  sensitive   = true
}

output "data_warehouse_type" {
  description = "Type of data warehouse deployed"
  value       = var.data_warehouse_type
}

# ===== SSH CONNECTION COMMANDS =====
output "ssh_commands" {
  description = "SSH commands to connect to VMs"
  value = {
    kafka   = "gcloud compute ssh ${module.compute.kafka_vm_name} --zone=${var.zone}"
    spark   = "gcloud compute ssh ${module.compute.spark_vm_name} --zone=${var.zone}"
    airflow = "gcloud compute ssh ${module.compute.airflow_vm_name} --zone=${var.zone}"
  }
}

# ===== QUICK START GUIDE =====
output "quick_start_guide" {
  description = "Quick start commands"
  value = <<-EOT
    # Connect to VMs:
    ${join("\n    ", [for k, v in {
      kafka   = "gcloud compute ssh ${module.compute.kafka_vm_name} --zone=${var.zone}"
      spark   = "gcloud compute ssh ${module.compute.spark_vm_name} --zone=${var.zone}"
      airflow = "gcloud compute ssh ${module.compute.airflow_vm_name} --zone=${var.zone}"
    } : "${k}: ${v}"])}
    
    # Service Account: ${module.iam.service_account_email}
    # Data Warehouse: ${var.data_warehouse_type}
    
    # Next steps:
    # 1. SSH to each VM and install Docker
    # 2. Copy your docker-compose.yml to the appropriate VMs
    # 3. Configure data warehouse connections
    # 4. Start your services with docker-compose up -d
  EOT
}