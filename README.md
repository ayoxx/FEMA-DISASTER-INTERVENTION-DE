
# FEMA-DISASTER-INTERVENTION-DE

A concise guide and status for the serverless ETL pipeline implemented in this repository.

Overview
--------
This project prototypes a Google Cloud serverless ETL pipeline that:

- extracts JSON from a public API (FEMA Public Assistance endpoint),
- stores raw payloads in Google Cloud Storage (raw/bronze),
- transforms and normalises records (PySpark / Python), and
- loads analytics-ready tables into BigQuery.

Pipeline architecture
---------------------
PUBLIC API → Cloud Scheduler → Cloud Run / Cloud Function (`extract_data.py`) → GCS (raw) → Transformation → BigQuery

What exists in this repo
------------------------
- `extract_data.py` — extraction script that fetches the API and writes `data.json` (adaptable to Cloud Run / Cloud Functions).
- `data.json` — sample payload saved from a local run.
- `requirements.txt` — Python dependencies for local testing and development.

How to run locally
-------------------
1. Create and activate a virtualenv:

2. Install dependencies:

Cloud deployment notes
----------------------
- Create a dedicated service account for the function (e.g. `fema-function-sa`) and grant `roles/storage.objectCreator` on the target bucket.
- Deploy as Cloud Run or Cloud Function and configure the service to use the service account.
- Use Cloud Scheduler with OIDC authentication (Scheduler service account) to invoke the function on a schedule.

Troubleshooting checklist
-------------------------
- If uploads are missing from the bucket, confirm the function's service account has `Storage Object Creator` on the exact bucket name.
- Check Cloud Run / Cloud Function logs in Cloud Logging for errors and stack traces.
- Verify the client project and bucket visibility using `gcloud` / `gsutil`:

Next steps
----------
- Add ingestion metadata (timestamp, HTTP status, record counts) and write `data_meta.json` alongside raw payloads.
- Implement transformation (PySpark) and load jobs to BigQuery.
- Codify infrastructure with Terraform and add CI/CD.





