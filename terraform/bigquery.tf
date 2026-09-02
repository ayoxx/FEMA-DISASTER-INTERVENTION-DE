
resource "google_bigquery_dataset" "bronze" {
  dataset_id = "fema_dev_bronze"
  location   = var.region

  description = "Bronze layer containing raw FEMA API data"
}

resource "google_bigquery_table" "public_assistance_raw" {
  dataset_id = google_bigquery_dataset.bronze.dataset_id
  table_id   = "public_assistance_raw"

  schema = jsonencode([
    {
      name = "source_file"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "payload"
      type = "JSON"
      mode = "NULLABLE"
    },
    {
      name = "ingestion_timestamp"
      type = "TIMESTAMP"
      mode = "NULLABLE"
    }
  ])
}