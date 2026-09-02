
# Automatically ZIP your extractor
data "archive_file" "extractor" {
  type        = "zip"
  source_dir  = "${path.module}/../functions/extractor"
  output_path = "${path.module}/extractor.zip"
}

# Automatically ZIP your Bronze loader
data "archive_file" "bronze_loader" {
  type        = "zip"
  source_dir  = "${path.module}/../functions/bronze_loader"
  output_path = "${path.module}/bronze_loader.zip"
}

# Upload the ZIP files to GCS
resource "google_storage_bucket_object" "extractor_source" {
  name   = "extractor-${data.archive_file.extractor.output_md5}.zip"
  bucket = google_storage_bucket.function_source.name
  source = data.archive_file.extractor.output_path
}

resource "google_storage_bucket_object" "bronze_loader_source" {
  name   = "bronze-loader-${data.archive_file.bronze_loader.output_md5}.zip"
  bucket = google_storage_bucket.function_source.name
  source = data.archive_file.bronze_loader.output_path
}
