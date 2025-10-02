# Compute module - VM instances for Kafka, Spark, and Airflow

# Startup script for all VMs - installs Docker and docker-compose
locals {
  startup_script = <<-EOF
    #!/bin/bash
    
    # Update system
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    
    # Install Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io
    
    # Install Docker Compose
    curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    # Add user to docker group
    usermod -aG docker $USER
    
    # Start and enable Docker
    systemctl start docker
    systemctl enable docker
    
    # Create directories for applications
    mkdir -p /opt/data-pipeline
    chown -R $USER:$USER /opt/data-pipeline
    
    # Install additional tools
    apt-get install -y htop vim git curl wget
    
    echo "VM setup completed" > /var/log/startup-script.log
  EOF
}

# Kafka VM
resource "google_compute_instance" "kafka_vm" {
  name         = "${var.name_prefix}-kafka-vm"
  machine_type = var.kafka_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 50  # GB
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.subnet_name
    
    # Assign external IP
    access_config {
      // Ephemeral public IP
    }
  }

  # Service account for VM
  service_account {
    email  = google_service_account.vm_service_account.email
    scopes = ["cloud-platform"]
  }

  # Network tags for firewall rules
  tags = ["ssh-allowed", "kafka-server"]

  # Startup script
  metadata_startup_script = local.startup_script

  # Metadata
  metadata = {
    environment = var.environment
    role        = "kafka"
  }

  labels = {
    environment = var.environment
    role        = "kafka"
    managed_by  = "terraform"
  }
}

# Spark VM
resource "google_compute_instance" "spark_vm" {
  name         = "${var.name_prefix}-spark-vm"
  machine_type = var.spark_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 100  # GB - larger for Spark data processing
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.subnet_name
    
    # Assign external IP
    access_config {
      // Ephemeral public IP
    }
  }

  # Service account for VM
  service_account {
    email  = google_service_account.vm_service_account.email
    scopes = ["cloud-platform"]
  }

  # Network tags for firewall rules
  tags = ["ssh-allowed", "spark-server"]

  # Startup script
  metadata_startup_script = local.startup_script

  # Metadata
  metadata = {
    environment = var.environment
    role        = "spark"
  }

  labels = {
    environment = var.environment
    role        = "spark"
    managed_by  = "terraform"
  }
}

# Airflow VM
resource "google_compute_instance" "airflow_vm" {
  name         = "${var.name_prefix}-airflow-vm"
  machine_type = var.airflow_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 50  # GB
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.subnet_name
    
    # Assign external IP
    access_config {
      // Ephemeral public IP
    }
  }

  # Service account for VM
  service_account {
    email  = google_service_account.vm_service_account.email
    scopes = ["cloud-platform"]
  }

  # Network tags for firewall rules
  tags = ["ssh-allowed", "airflow-server"]

  # Startup script
  metadata_startup_script = local.startup_script

  # Metadata
  metadata = {
    environment = var.environment
    role        = "airflow"
  }

  labels = {
    environment = var.environment
    role        = "airflow"
    managed_by  = "terraform"
  }
}

# Service account for VMs
resource "google_service_account" "vm_service_account" {
  account_id   = "${var.name_prefix}-vm-sa"
  display_name = "Service Account for ${var.environment} Data Pipeline VMs"
  description  = "Service account used by Kafka, Spark, and Airflow VMs"
}

# IAM binding for service account
resource "google_project_iam_member" "vm_service_account_roles" {
  for_each = toset([
    "roles/compute.instanceAdmin.v1",
    "roles/storage.admin",
    "roles/bigquery.admin",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.vm_service_account.email}"
}