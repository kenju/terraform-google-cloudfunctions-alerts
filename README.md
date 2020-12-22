# terraform-google-cloudfunctions-alerts

## Usage

```terraform
resource "google_monitoring_notification_channel" "slack" {
  display_name = "GCP Monitoring"
  type         = "slack"
  labels = {
    "channel_name" = "#sre"
    "auth_token"   = ""
  }
}

module "cloudfunctions-alerts" {
  source  = "google-cloudfunctions-alerts"
  project = google_project.foo.project_id
  region  = "asia-northeast1"
  notification_channels = [
    google_monitoring_notification_channel.slack.id,
  ]
  functions = [
    google_cloudfunctions_function.foo,
    google_cloudfunctions_function.bar,
    google_cloudfunctions_function.buz,
  ]
  overrides = {
    memoryusage_high = {
      threshold = 1.0
    }
    executiontimes_high = {
      threshold = 1.0
    }
  }
}
```
