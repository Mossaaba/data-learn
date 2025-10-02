# Data Warehouse module outputs

# Connection information based on warehouse type
output "connection_info" {
  description = "Data warehouse connection information"
  value = var.data_warehouse_type == "bigquery" ? {
    type       = "bigquery"
    project_id = var.project_id
    dataset_id = var.bigquery_dataset_id
    location   = var.region
    tables = {
      raw_data       = google_bigquery_table.raw_data_table[0].table_id
      processed_data = google_bigquery_table.processed_data_table[0].table_id
    }
  } : var.data_warehouse_type == "redshift" ? {
    type     = "redshift"
    host     = aws_redshift_cluster.main_cluster[0].endpoint
    port     = aws_redshift_cluster.main_cluster[0].port
    database = aws_redshift_cluster.main_cluster[0].database_name
    username = aws_redshift_cluster.main_cluster[0].master_username
  } : var.data_warehouse_type == "snowflake" ? {
    type      = "snowflake"
    account   = var.snowflake_account
    database  = snowflake_database.main_database[0].name
    warehouse = snowflake_warehouse.main_warehouse[0].name
    schema    = snowflake_schema.main_schema[0].name
  } : {}
  sensitive = true
}

# BigQuery specific outputs
output "bigquery_dataset_id" {
  description = "BigQuery dataset ID"
  value       = var.data_warehouse_type == "bigquery" ? google_bigquery_dataset.main_dataset[0].dataset_id : null
}

output "bigquery_project_id" {
  description = "BigQuery project ID"
  value       = var.data_warehouse_type == "bigquery" ? var.project_id : null
}

# Redshift specific outputs
output "redshift_endpoint" {
  description = "Redshift cluster endpoint"
  value       = var.data_warehouse_type == "redshift" ? aws_redshift_cluster.main_cluster[0].endpoint : null
  sensitive   = true
}

output "redshift_port" {
  description = "Redshift cluster port"
  value       = var.data_warehouse_type == "redshift" ? aws_redshift_cluster.main_cluster[0].port : null
}

# Snowflake specific outputs
output "snowflake_database" {
  description = "Snowflake database name"
  value       = var.data_warehouse_type == "snowflake" ? snowflake_database.main_database[0].name : null
}

output "snowflake_warehouse" {
  description = "Snowflake warehouse name"
  value       = var.data_warehouse_type == "snowflake" ? snowflake_warehouse.main_warehouse[0].name : null
}