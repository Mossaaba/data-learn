# Monitoring module outputs

output "budget_name" {
  description = "Name of the billing budget"
  value       = google_billing_budget.data_pipeline_budget.display_name
}

output "notification_channel_name" {
  description = "Name of the email notification channel"
  value       = google_monitoring_notification_channel.email_notification.name
}

output "alert_policies" {
  description = "Names of created alert policies"
  value = {
    high_cpu_usage    = google_monitoring_alert_policy.high_cpu_usage.display_name
    high_memory_usage = google_monitoring_alert_policy.high_memory_usage.display_name
    high_disk_usage   = google_monitoring_alert_policy.high_disk_usage.display_name
    high_error_rate   = google_monitoring_alert_policy.high_error_rate.display_name
  }
}

output "uptime_check_name" {
  description = "Name of the Airflow uptime check"
  value       = google_monitoring_uptime_check_config.airflow_uptime_check.display_name
}

output "log_metric_name" {
  description = "Name of the error count log metric"
  value       = google_logging_metric.error_count.name
}