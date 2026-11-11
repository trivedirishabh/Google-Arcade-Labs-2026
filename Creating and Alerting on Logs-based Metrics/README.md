# Creating and Alerting on Logs-based Metrics

This lab sets up monitoring resources, deploys a sample telemetry application to Google Kubernetes Engine, creates a logs-based metric and alert policy, and generates test errors.

## Prerequisites

- A Google Cloud project with billing enabled and `gcloud`, `kubectl`, Docker, `wget`, `unzip`, `jq`, `curl`, and Python 3 installed
- Authentication and permissions to create a GKE cluster, Artifact Registry repository, Monitoring policies, and Logging metrics
- A notification channel named `VM Stop Alert Email`

## Before running

Review `script.sh` and update its hard-coded project IDs, email address, region/zone, resource names, and notification-channel assumptions. The script creates a GKE cluster and other cloud resources, pushes a container image, deploys a service, creates monitoring resources, and generates requests. These actions may incur charges.

The script contains a masked `Authorization` header (`******`) in its Monitoring API calls; those requests are likely to fail unless valid authentication is configured. The script also downloads and executes third-party lab assets, so inspect its commands and sources before use.

## Run

After confirming prerequisites and reviewing the script, run it from this directory:

```bash
bash script.sh
```
