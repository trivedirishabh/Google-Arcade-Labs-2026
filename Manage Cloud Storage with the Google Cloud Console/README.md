# Manage Cloud Storage with the Google Cloud Console

This lab demonstrates creating a Cloud Storage bucket, uploading an image, organizing it in folders, and configuring bucket access.

## Prerequisites

- A Google Cloud project with billing enabled
- Access to the Google Cloud Console or authenticated `gcloud` CLI
- Permission to create buckets, manage objects, and change bucket IAM policies

## Before running

Review `script.sh` and update the hard-coded bucket name and project-specific settings for your lab. The script creates a bucket in `us-central1`, downloads a sample image, creates folders, and grants `allUsers` the `roles/storage.objectViewer` role on the bucket. This makes its objects publicly readable. Remove that binding when public access is no longer needed.

Cloud Storage usage may incur charges.

## Run

Run from this directory in an authenticated shell:

```bash
bash script.sh
```
