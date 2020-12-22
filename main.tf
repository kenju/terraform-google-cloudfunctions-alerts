locals {
  function_names = [for f in var.functions : f["name"]]
  # [Hash<K, V>]: K=function_name, V=google_cloudfunctions_function
  function_maps = zipmap(local.function_names, var.functions)
}

locals {
  memoryusage_high = merge({
    enabled               = true
    notification_channels = var.notification_channels
    threshold             = 0.8
  }, lookup(var.overrides, "memoryusage_high", {}))
}

resource "google_monitoring_alert_policy" "cloudfunction-memoryusage-high" {
  for_each = local.function_maps

  enabled               = local.memoryusage_high.enabled
  project               = var.project
  display_name          = "CloudFunctionMemoryUsageHigh-${each.value.name}"
  combiner              = "OR"
  notification_channels = local.memoryusage_high.notification_channels
  conditions {
    display_name = "Cloud Function - Memory usage for ${each.value.name} [MAX]"
    condition_threshold {
      filter     = "metric.type=\"cloudfunctions.googleapis.com/function/user_memory_bytes\" resource.type=\"cloud_function\" resource.label.\"function_name\"=\"${each.value.name}\""
      duration   = "0s"
      comparison = "COMPARISON_GT"
      # functions.user_memory_bytes is Bytes https://cloud.google.com/monitoring/api/metrics_gcp
      # google_cloudfunctions_function.available_memory_mb is MB https://www.terraform.io/docs/providers/google/d/cloudfunctions_function.html#runtime
      threshold_value = each.value.available_memory_mb * 1000 * 1000 * local.memoryusage_high.threshold # MB to Bytes
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_PERCENTILE_99"
        cross_series_reducer = "REDUCE_MAX"
      }
      trigger {
        count   = 1
        percent = 0
      }
    }
  }
  documentation {
    content   = "Increase the memory limit from the [GCP Console](https://console.cloud.google.com/functions/details/${var.region}/${each.value.name}?project=${var.project})"
    mime_type = "text/markdown"
  }
}

locals {
  executiontimes_high = merge({
    enabled               = true
    notification_channels = var.notification_channels
    threshold             = 0.8
  }, lookup(var.overrides, "executiontimes_high", {}))
}

resource "google_monitoring_alert_policy" "cloudfunction-executiontimes-high" {
  for_each = local.function_maps

  enabled               = local.executiontimes_high.enabled
  project               = var.project
  display_name          = "CloudFunctionExecutionTimesHigh-${each.value.name}"
  combiner              = "OR"
  notification_channels = local.executiontimes_high.notification_channels
  conditions {
    display_name = "Cloud Function - Execution times for ${each.value.name} [MAX]"
    condition_threshold {
      filter     = "metric.type=\"cloudfunctions.googleapis.com/function/execution_times\" resource.type=\"cloud_function\" resource.label.\"function_name\"=\"${each.value.name}\""
      duration   = "0s"
      comparison = "COMPARISON_GT"
      # functions.execution_times is nanosecond https://cloud.google.com/monitoring/api/metrics_gcp
      # google_cloudfunctions_function.timeout is second https://www.terraform.io/docs/providers/google/d/cloudfunctions_function.html#runtime
      threshold_value = each.value.timeout * 1000 * 1000 * 1000 * local.executiontimes_high.threshold # second to nanosec
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_PERCENTILE_99"
        cross_series_reducer = "REDUCE_MAX"
      }
      trigger {
        count   = 1
        percent = 0
      }
    }
  }
  documentation {
    content   = "Increase the execution timeout from the [GCP Console](https://console.cloud.google.com/functions/details/${var.region}/${each.value.name}?project=${var.project})"
    mime_type = "text/markdown"
  }
}
