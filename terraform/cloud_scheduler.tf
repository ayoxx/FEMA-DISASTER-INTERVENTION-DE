
resource "google_cloud_scheduler_job" "fema_extractor" {
  name     = "fema-extractor-schedule"
  region   = var.region
  schedule = "0 */6 * * *"

  http_target {
    # Use the extractor function's name (the function resource must be deployed
    # and will provide an HTTPS trigger URL at deploy time). For validation this
    # references the declared function resource to avoid undeclared resource errors.
    uri         = google_cloudfunctions2_function.extractor.service_config[0].uri
    http_method = "POST"

    oidc_token {
      service_account_email = google_service_account.extractor.email
    }
  }
}

# IAM for scheduler 
resource "google_cloud_run_v2_service_iam_member" "scheduler_invoker" {
  # Grant invoker role against the extractor function's service
  name     = google_cloudfunctions2_function.extractor.name
  location = var.region

  role   = "roles/run.invoker"
  member = "serviceAccount:${google_service_account.extractor.email}"
}