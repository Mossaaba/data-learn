# Data Warehouse module - Abstracted support for BigQuery, Redshift, and Snowflake

# BigQuery resources (when data_warehouse_type = "bigquery")
resource "google_bigquery_dataset" "main_dataset" {
  count       = var.data_warehouse_type == "bigquery" ? 1 : 0
  dataset_id  = var.bigquery_dataset_id
  location    = var.region
  description = "Main dataset for ${var.environment} data pipeline"

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }

  # Access control
  access {
    role          = "OWNER"
    user_by_email = data.google_client_openid_userinfo.me[0].email
  }

  # Delete protection
  delete_contents_on_destroy = var.environment != "prod"
}

# BigQuery tables
resource "google_bigquery_table" "raw_data_table" {
  count      = var.data_warehouse_type == "bigquery" ? 1 : 0
  dataset_id = google_bigquery_dataset.main_dataset[0].dataset_id
  table_id   = "raw_data"

  description = "Raw data ingestion table"

  schema = jsonencode([
    {
      name = "id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "timestamp"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "data"
      type = "JSON"
      mode = "NULLABLE"
    },
    {
      name = "source"
      type = "STRING"
      mode = "NULLABLE"
    }
  ])

  labels = {
    environment = var.environment
    table_type  = "raw_data"
  }
}

resource "google_bigquery_table" "processed_data_table" {
  count      = var.data_warehouse_type == "bigquery" ? 1 : 0
  dataset_id = google_bigquery_dataset.main_dataset[0].dataset_id
  table_id   = "processed_data"

  description = "Processed data table"

  schema = jsonencode([
    {
      name = "id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "processed_timestamp"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "processed_data"
      type = "JSON"
      mode = "NULLABLE"
    },
    {
      name = "processing_status"
      type = "STRING"
      mode = "NULLABLE"
    }
  ])

  labels = {
    environment = var.environment
    table_type  = "processed_data"
  }
}

# Get current user info for BigQuery access
data "google_client_openid_userinfo" "me" {
  count = var.data_warehouse_type == "bigquery" ? 1 : 0
}

# AWS Redshift resources (when data_warehouse_type = "redshift")
resource "aws_redshift_cluster" "main_cluster" {
  count = var.data_warehouse_type == "redshift" ? 1 : 0
  
  cluster_identifier = var.redshift_cluster_id
  database_name      = var.redshift_database_name
  master_username    = var.redshift_master_username
  master_password    = var.redshift_master_password
  
  node_type       = "dc2.large"
  cluster_type    = "single-node"
  
  # Security
  publicly_accessible = false
  encrypted          = true
  
  # Backup
  automated_snapshot_retention_period = 7
  
  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Redshift subnet group
resource "aws_redshift_subnet_group" "main_subnet_group" {
  count = var.data_warehouse_type == "redshift" ? 1 : 0
  
  name       = "${var.name_prefix}-redshift-subnet-group"
  subnet_ids = [aws_subnet.redshift_subnet_1[0].id, aws_subnet.redshift_subnet_2[0].id]

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# VPC for Redshift (simplified)
resource "aws_vpc" "redshift_vpc" {
  count = var.data_warehouse_type == "redshift" ? 1 : 0
  
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.name_prefix}-redshift-vpc"
    Environment = var.environment
  }
}

# Subnets for Redshift
resource "aws_subnet" "redshift_subnet_1" {
  count = var.data_warehouse_type == "redshift" ? 1 : 0
  
  vpc_id            = aws_vpc.redshift_vpc[0].id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.name_prefix}-redshift-subnet-1"
  }
}

resource "aws_subnet" "redshift_subnet_2" {
  count = var.data_warehouse_type == "redshift" ? 1 : 0
  
  vpc_id            = aws_vpc.redshift_vpc[0].id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "${var.name_prefix}-redshift-subnet-2"
  }
}

# Snowflake resources (when data_warehouse_type = "snowflake")
resource "snowflake_database" "main_database" {
  count = var.data_warehouse_type == "snowflake" ? 1 : 0
  
  name    = var.snowflake_database
  comment = "Main database for ${var.environment} data pipeline"
}

resource "snowflake_warehouse" "main_warehouse" {
  count = var.data_warehouse_type == "snowflake" ? 1 : 0
  
  name           = var.snowflake_warehouse
  warehouse_size = "X-SMALL"
  auto_suspend   = 60
  auto_resume    = true
  comment        = "Main warehouse for ${var.environment} data pipeline"
}

resource "snowflake_schema" "main_schema" {
  count = var.data_warehouse_type == "snowflake" ? 1 : 0
  
  database = snowflake_database.main_database[0].name
  name     = var.snowflake_schema
  comment  = "Main schema for data pipeline tables"
}

# Snowflake tables
resource "snowflake_table" "raw_data_table" {
  count = var.data_warehouse_type == "snowflake" ? 1 : 0
  
  database = snowflake_database.main_database[0].name
  schema   = snowflake_schema.main_schema[0].name
  name     = "RAW_DATA"
  comment  = "Raw data ingestion table"

  column {
    name = "ID"
    type = "VARCHAR(255)"
  }

  column {
    name = "TIMESTAMP"
    type = "TIMESTAMP"
  }

  column {
    name = "DATA"
    type = "VARIANT"
  }

  column {
    name = "SOURCE"
    type = "VARCHAR(255)"
  }
}