
resource "google_cloudfunctions2_function" "extractor" {
  name     = "fema-dev-extractor"
  location = var.region

  build_config {
    runtime     = "python314"
    entry_point = "extract_and_load"

    source {
      storage_source {
        bucket = google_storage_bucket.function_source.name
        object = google_storage_bucket_object.extractor_source.name
      }
    }
  }

  service_config {
    available_memory      = "512M"
    timeout_seconds       = 120
    service_account_email = google_service_account.extractor.email

    environment_variables = {
      PROJECT_ID  = var.project_id
      API_URL     = "https://www.fema.gov/api/open/v2/PublicAssistanceFundedProjectsDetails"
      BUCKET_NAME = google_storage_bucket.raw.name
    }
  }
}


resource "google_cloudfunctions2_function" "bronze_loader" {
  name     = "fema-dev-bronze-loader"
  location = var.region

  build_config {
    runtime     = "python314"
    entry_point = "load_to_bigquery"

    source {
      storage_source {
        bucket = google_storage_bucket.function_source.name
        object = google_storage_bucket_object.bronze_loader_source.name
      }
    }
  }

  service_config {
    available_memory      = "512M"
    timeout_seconds       = 120
    service_account_email = google_service_account.loader.email

    environment_variables = {
      PROJECT_ID  = var.project_id
      BQ_DATASET  = google_bigquery_dataset.bronze.dataset_id
      BQ_TABLE    = google_bigquery_table.public_assistance_raw.table_id
      API_URL     = "https://www.fema.gov/api/open/v2/PublicAssistanceFundedProjectsDetails"
      BUCKET_NAME = google_storage_bucket.raw.name
    }
  }
}