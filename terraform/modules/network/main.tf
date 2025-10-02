# Network module - VPC and firewall configuration

# Create VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "${var.name_prefix}-network"
  auto_create_subnetworks = false
  description             = "VPC network for ${var.environment} data pipeline"
}

# Create subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.name_prefix}-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  description   = "Subnet for ${var.environment} data pipeline VMs"
}

# Firewall rule for SSH access
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.name_prefix}-allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-allowed"]
  description   = "Allow SSH access to VMs"
}

# Firewall rule for Kafka
resource "google_compute_firewall" "allow_kafka" {
  name    = "${var.name_prefix}-allow-kafka"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["9092", "2181"]  # Kafka and Zookeeper ports
  }

  source_ranges = ["10.0.0.0/24"]  # Only internal network
  target_tags   = ["kafka-server"]
  description   = "Allow Kafka and Zookeeper traffic"
}

# Firewall rule for Spark
resource "google_compute_firewall" "allow_spark" {
  name    = "${var.name_prefix}-allow-spark"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["8888", "4040", "7077", "8080"]  # Jupyter, Spark UI, Spark master, Spark web UI
  }

  source_ranges = ["0.0.0.0/0"]  # Allow external access to Jupyter
  target_tags   = ["spark-server"]
  description   = "Allow Spark and Jupyter traffic"
}

# Firewall rule for Airflow
resource "google_compute_firewall" "allow_airflow" {
  name    = "${var.name_prefix}-allow-airflow"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["8081", "5432"]  # Airflow web UI and PostgreSQL
  }

  source_ranges = ["0.0.0.0/0"]  # Allow external access to Airflow UI
  target_tags   = ["airflow-server"]
  description   = "Allow Airflow web UI and database traffic"
}

# Firewall rule for internal communication
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.name_prefix}-allow-internal"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/24"]
  description   = "Allow all internal traffic within the subnet"
}