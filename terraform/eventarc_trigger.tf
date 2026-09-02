
resource "google_eventarc_trigger" "gcs_to_bronze" {
  name     = "fema-gcs-to-bronze"
  location = var.region

  matching_criteria {
    attribute = "type"
    value     = "google.cloud.storage.object.v1.finalized"
  }

  matching_criteria {
    attribute = "bucket"
    value     = google_storage_bucket.raw.name
  }

  destination {
    # Route the event to the Bronze loader service.
    # Eventarc delivers to Cloud Run services; Cloud Functions (2nd gen) are
    # implemented on Cloud Run under the hood, so use a Cloud Run destination.
    cloud_run_service {
      service = google_cloudfunctions2_function.bronze_loader.name
      region  = var.region
    }
  }

  # Use the loader service account defined in `service_accounts.tf`
  service_account = google_service_account.loader.email
}