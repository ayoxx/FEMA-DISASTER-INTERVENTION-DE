
"""Fetch JSON from the FEMA Public Assistance API and save to a file.

This module contains a tiny, focused extractor used during development to
pull the API payload and persist it locally as `data.json` for downstream
analysis or testing.
"""

import json
import requests


# API endpoint for FEMA Public Assistance Funded Projects Details
API_URL = "https://www.fema.gov/api/open/v2/PublicAssistanceFundedProjectsDetails"


def extract_data():
    """Perform an HTTP GET against the configured API and return parsed JSON.

    The function uses `requests.get` with a 30 second timeout and
    calls `raise_for_status()` to surface HTTP errors as exceptions so the
    caller can handle or fail fast.
    """
    response = requests.get(API_URL, timeout=30)
    # Raise an exception for 4xx/5xx responses instead of returning invalid data
    response.raise_for_status()

    # Parse and return the response body as a native Python object
    return response.json()


if __name__ == "__main__":
    # Run the extractor when the script is executed directly
    data = extract_data()

    # Persist the fetched JSON to a local file with pretty-printing
    with open("data.json", "w") as file:
        json.dump(data, file, indent=2)
    
