# Monitoring and Logging for Cloud Run Functions

This lab deploys a small HTTP function to Cloud Run, generates test traffic, and creates a Cloud Logging metric to extract request latency.

## Prerequisites

- A Google Cloud project with billing enabled and `gcloud`, `curl`, and `tar` installed
- Authentication and permissions to enable Cloud Run, Cloud Build, and Artifact Registry APIs; deploy Cloud Run services; and create logging metrics

## Run

Review `script.sh` before running. It deploys the `helloworld` service in `us-east4` with unauthenticated access, downloads the Vegeta load-testing tool, sends 200 requests per second for five minutes, and creates a latency metric. This load test can generate usage and charges. Confirm that the project and service access settings are appropriate.

Run it from this directory in an authenticated shell:

```bash
bash script.sh
```
