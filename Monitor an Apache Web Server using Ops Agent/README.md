# Monitor an Apache Web Server using Ops Agent

This lab creates a Compute Engine VM, installs Apache and the Google Cloud Ops Agent, configures Apache log and metric collection, and creates a Cloud Monitoring alert policy.

## Prerequisites

- A Google Cloud project with billing enabled and `gcloud` installed
- Authentication and permissions to create Compute Engine instances and firewall rules, enable Cloud Monitoring, create notification channels, and create alert policies
- The `DEVSHELL_PROJECT_ID` environment variable set to the project to use

## Before running

Review `script.sh` and replace the example email address in the alert-channel command with an address you control. The script opens HTTP and HTTPS firewall access for the VM, installs software, and creates monitoring resources; these may incur charges. Confirm the network exposure and project are appropriate before continuing.

## Run

Run the script from this directory in an authenticated shell:

```bash
bash script.sh
```
