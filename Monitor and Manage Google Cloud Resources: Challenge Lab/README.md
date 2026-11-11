# Monitor and Manage Google Cloud Resources: Challenge Lab

This lab provisions a Cloud Storage bucket and Pub/Sub topic, deploys a Cloud Function triggered by uploaded images, and generates 64×64 thumbnails that are also published to Pub/Sub.

## Prerequisites

- A Google Cloud project with billing enabled and `gcloud` authenticated
- Node.js source deployment support and permission to enable APIs, create buckets and topics, and deploy a second-generation Cloud Function
- Permission to change project IAM policies

## Before running

Review `script.sh` and update the hard-coded bucket name, topic, function name, region, and user email. The script enables several APIs, creates resources, grants a project-level Storage Object Viewer role to a user, and deploys a function triggered by bucket uploads. Confirm those IAM and trigger settings are appropriate. Cloud resources and image processing may incur charges.

## Run

Run from this directory in an authenticated shell after updating the configuration:

```bash
bash script.sh
```
