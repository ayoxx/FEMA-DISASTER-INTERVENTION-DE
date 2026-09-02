
import os
import json
from datetime import datetime, timezone

import requests
from google.cloud import storage

API_URL = os.environ["API_URL"]
BUCKET_NAME = os.environ["BUCKET_NAME"]


# API_URL = "https://www.fema.gov/api/open/v2/PublicAssistanceFundedProjectsDetails"

# BUCKET_NAME = "fema-raw-bucket"


def extract_data():
    """Extract JSON data from the FEMA Public Assistance API."""

    response = requests.get(API_URL, timeout=30)
    response.raise_for_status()

    return response.json()


def upload_to_gcs(data):
    """Upload extracted JSON data to Google Cloud Storage."""

    storage_client = storage.Client()

    bucket = storage_client.bucket(BUCKET_NAME)

    current_time = datetime.now(timezone.utc)

    object_name = (
        f"raw/fema/public_assistance/"
        f"{current_time:%Y/%m/%d}/"
        f"data_{current_time:%Y%m%d_%H%M%S}.json"
    )

    blob = bucket.blob(object_name)

    json_data = json.dumps(data, indent=2)

    blob.upload_from_string(
        json_data,
        content_type="application/json",
    )

    return object_name


def extract_and_load(request):
    """Cloud Run function entry point."""

    try:
        data = extract_data()

        object_name = upload_to_gcs(data)

        return {
            "status": "success",
            "message": "Data successfully extracted and uploaded to GCS.",
            "gcs_object": object_name,
        }, 200

    except requests.exceptions.RequestException as error:
        print(f"API request failed: {error}")

        return {
            "status": "error",
            "message": "Failed to retrieve data from FEMA API.",
            "error": str(error),
        }, 500

    except Exception as error:
        print(f"Unexpected error: {error}")

        return {
            "status": "error",
            "message": "Unexpected error occurred.",
            "error": str(error),
        }, 500