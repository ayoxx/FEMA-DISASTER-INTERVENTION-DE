
resource "google_service_account" "extractor" {
  account_id   = "fema-extractor-sa"
  display_name = "FEMA Extractor Service Account"
}

resource "google_service_account" "loader" {
  account_id   = "fema-loader-sa"
  display_name = "FEMA Bronze Loader Service Account"
}

resource "google_storage_bucket_iam_member" "loader_storage_reader" {
  bucket = google_storage_bucket.raw.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.loader.email}"
}

resource "google_project_iam_member" "loader_bigquery_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.loader.email}"
}

resource "google_project_iam_member" "loader_bigquery_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.loader.email}"
}

resource "google_project_iam_member" "loader_eventarc_receiver" {
  project = var.project_id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.loader.email}"
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_iam_member" "cloud_storage_pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"
}

resource "google_storage_bucket_iam_member" "extractor_storage_creator" {
  bucket = google_storage_bucket.raw.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.extractor.email}"
}

resource "google_cloud_run_v2_service_iam_member" "loader_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloudfunctions2_function.bronze_loader.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.loader.email}"

  depends_on = [
    google_cloudfunctions2_function.bronze_loader
  ]
}