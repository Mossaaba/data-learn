# Monitoring module - Budget alerts and notifications

# Budget for cost monitoring
resource "google_billing_budget" "data_pipeline_budget" {
  billing_account = var.billing_account
  display_name    = "${var.name_prefix} Budget"

  budget_filter {
    projects = ["projects/${var.project_id}"]
    
    # Filter by labels to only include our resources
    labels = {
      "environment" = [var.environment]
    }
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = tostring(var.budget_amount)
    }
  }

  # Alert thresholds
  threshold_rules {
    threshold_percent = 0.5  # 50%
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    threshold_percent = 0.8  # 80%
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    threshold_percent = 1.0  # 100%
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    threshold_percent = 1.2  # 120%
    spend_basis       = "FORECASTED_SPEND"
  }

  # Notification channels
  all_updates_rule {
    monitoring_notification_channels = [
      google_monitoring_notification_channel.email_notification.name
    ]
    disable_default_iam_recipients = false
  }
}

# Email notification channel
resource "google_monitoring_notification_channel" "email_notification" {
  display_name = "${var.name_prefix} Email Notifications"
  type         = "email"
  
  labels = {
    email_address = var.alert_email
  }

  description = "Email notifications for ${var.environment} data pipeline alerts"
}

# Alerting policy for high CPU usage
resource "google_monitoring_alert_policy" "high_cpu_usage" {
  display_name = "${var.name_prefix} High CPU Usage"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "VM Instance - CPU utilization"
    
    condition_threshold {
      filter          = "resource.type=\"gce_instance\" AND resource.labels.project_id=\"${var.project_id}\""
      duration        = "300s"
      comparison      = "COMPARISON_GREATER_THAN"
      threshold_value = 0.8  # 80%
      
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.email_notification.name
  ]

  alert_strategy {
    auto_close = "1800s"  # 30 minutes
  }
}

# Alerting policy for high memory usage
resource "google_monitoring_alert_policy" "high_memory_usage" {
  display_name = "${var.name_prefix} High Memory Usage"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "VM Instance - Memory utilization"
    
    condition_threshold {
      filter          = "resource.type=\"gce_instance\" AND resource.labels.project_id=\"${var.project_id}\""
      duration        = "300s"
      comparison      = "COMPARISON_GREATER_THAN"
      threshold_value = 0.85  # 85%
      
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.email_notification.name
  ]

  alert_strategy {
    auto_close = "1800s"  # 30 minutes
  }
}

# Alerting policy for disk usage
resource "google_monitoring_alert_policy" "high_disk_usage" {
  display_name = "${var.name_prefix} High Disk Usage"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "VM Instance - Disk utilization"
    
    condition_threshold {
      filter          = "resource.type=\"gce_instance\" AND resource.labels.project_id=\"${var.project_id}\""
      duration        = "300s"
      comparison      = "COMPARISON_GREATER_THAN"
      threshold_value = 0.9  # 90%
      
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.email_notification.name
  ]

  alert_strategy {
    auto_close = "1800s"  # 30 minutes
  }
}

# Uptime check for Airflow web UI
resource "google_monitoring_uptime_check_config" "airflow_uptime_check" {
  display_name = "${var.name_prefix} Airflow Uptime Check"
  timeout      = "10s"
  period       = "300s"  # 5 minutes

  http_check {
    path         = "/health"
    port         = "8081"
    request_method = "GET"
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = "airflow-vm-external-ip"  # This would need to be dynamic
    }
  }

  content_matchers {
    content = "healthy"
    matcher = "CONTAINS_STRING"
  }
}

# Log-based metric for error counting
resource "google_logging_metric" "error_count" {
  name   = "${replace(var.name_prefix, "-", "_")}_error_count"
  filter = "resource.type=\"gce_instance\" AND severity>=ERROR AND labels.environment=\"${var.environment}\""

  metric_descriptor {
    metric_kind = "GAUGE"
    value_type  = "INT64"
    display_name = "${var.name_prefix} Error Count"
  }

  label_extractors = {
    "instance_name" = "EXTRACT(resource.labels.instance_id)"
  }
}

# Alert policy for error count
resource "google_monitoring_alert_policy" "high_error_rate" {
  display_name = "${var.name_prefix} High Error Rate"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "High error rate in logs"
    
    condition_threshold {
      filter          = "resource.type=\"logging_metric\" AND metric.type=\"logging.googleapis.com/user/${google_logging_metric.error_count.name}\""
      duration        = "300s"
      comparison      = "COMPARISON_GREATER_THAN"
      threshold_value = 10  # More than 10 errors in 5 minutes
      
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.email_notification.name
  ]

  alert_strategy {
    auto_close = "1800s"  # 30 minutes
  }
}