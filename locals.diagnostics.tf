locals {
  # Azure expands AllMetrics into concrete metric categories when diagnostic
  # settings are read at Storage service scopes. Normalize before calling the
  # generic diagnostic setting submodule to avoid a perpetual plan diff.
  #
  # Azure Files also exposes the SLI category. The other service scopes expose
  # only Capacity and Transaction.
  storage_service_metric_categories = {
    blob  = toset(["Capacity", "Transaction"])
    file  = toset(["Capacity", "SLI", "Transaction"])
    queue = toset(["Capacity", "Transaction"])
    table = toset(["Capacity", "Transaction"])
  }
  # The storage account scope returns AllMetrics unchanged, so only normalize
  # the four service scopes whose read responses contain concrete categories.
  storage_service_diagnostic_settings = {
    blob  = var.diagnostic_settings_blob
    file  = var.diagnostic_settings_file
    queue = var.diagnostic_settings_queue
    table = var.diagnostic_settings_table
  }
  storage_service_diagnostic_settings_normalized = {
    for service_name, diagnostic_settings in local.storage_service_diagnostic_settings : service_name => {
      for setting_name, setting in diagnostic_settings : setting_name => merge(setting, {
        metrics = setunion(
          # Preserve non-AllMetrics entries exactly as supplied. An explicitly
          # configured concrete category takes precedence over one generated
          # from AllMetrics, which also prevents duplicate category entries.
          toset([
            for metric in setting.metrics : metric
            if metric.category != "AllMetrics"
          ]),
          toset(flatten([
            for metric in setting.metrics : metric.category == "AllMetrics" ? [
              for category in local.storage_service_metric_categories[service_name] : {
                category         = category
                enabled          = metric.enabled
                retention_policy = metric.retention_policy
              }
              if !contains([
                for explicit_metric in setting.metrics : explicit_metric.category
                if explicit_metric.category != "AllMetrics"
              ], category)
            ] : []
          ]))
        )
      })
    }
  }
}
