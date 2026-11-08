# Create PDFs with Go and Cloud Run

This lab deploys a Go service to Cloud Run that converts documents uploaded to Cloud Storage into PDFs using LibreOffice. Cloud Storage notifications publish object events to Pub/Sub, which invokes the service. Generated PDFs are written to a separate bucket.

## Prerequisites

- A Google Cloud project with billing enabled and `gcloud`, Go, and Git installed
- Authentication and permissions to create Artifact Registry repositories, Cloud Run services, Cloud Storage buckets and notifications, Pub/Sub topics and subscriptions, and service accounts
- A configured `GOOGLE_CLOUD_PROJECT` environment variable

## Before running

Review `script.sh` and verify the project, region (`us-east4`), bucket names, and access settings. The script expects upload and processed buckets to exist and uses a `SERVICE_URL` variable for the Pub/Sub push endpoint; make sure these are correctly configured before running. The script clones source code, builds and deploys a service, creates cloud resources, and uploads sample files. These resources may incur charges.

## Run

From this directory, after reviewing and preparing the required resources and variables:

```bash
export GOOGLE_CLOUD_PROJECT="your-project-id"
# Set SERVICE_URL to the deployed service URL as required by the script.
bash script.sh
```
