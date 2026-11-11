# Monitor Multiple Google Cloud Projects with Cloud Monitoring

This lab configures a Cloud Monitoring metrics scope across two projects, creates a VM and resource group, and sets up an uptime check, alert policy, and dashboard.

## Prerequisites

- Two Google Cloud projects with billing enabled
- `gcloud`, `curl`, `jq`, and Python 3 installed and authenticated
- Permissions in both projects to create Compute Engine instances and configure Monitoring metrics scopes, groups, uptime checks, alert policies, and dashboards

## Before running

Review `script.sh` and provide the correct project IDs. The script creates a VM in the second project and monitoring resources there. It writes `uptime-policy.yaml` and `dashboard.yaml` in the current directory.

The Monitoring API requests contain a masked `Authorization: ******` header; they are likely to fail until valid authorization is configured. Verify notification and alert settings before applying them. The VM may incur charges.

## Run

After updating and reviewing the script, run it from this directory:

```bash
bash script.sh
```
