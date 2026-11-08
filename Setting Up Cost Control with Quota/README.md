# Setting Up Cost Control with Quota

This lab queries the public BigQuery WISE dataset and demonstrates checking and changing a BigQuery query-usage quota.

## Prerequisites

- A Google Cloud project with BigQuery enabled and `bq` and `gcloud` installed
- Authentication and permission to run BigQuery queries and view/update service quotas
- The `DEVSHELL_PROJECT_ID` environment variable set to the project to use

## Run

Review `script.sh` before running and confirm the quota metric, value, and unit are appropriate for your project. The script runs queries against a public dataset and attempts to change the project's BigQuery query-usage quota.

```bash
bash script.sh
```

Quota availability and update permissions vary by project. Check the command formatting and project variable in the script if a command fails.
