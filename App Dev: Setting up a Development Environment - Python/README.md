# App Dev: Setting up a Development Environment - Python

This lab prepares a Compute Engine VM as a Python development environment. The script creates a Debian VM, opens HTTP access, installs Python tooling, and copies lab assets onto the VM.

## Prerequisites

- A Google Cloud project with billing enabled and `gcloud` authenticated
- Permission to create Compute Engine instances and firewall rules, and to SSH/SCP to the VM
- `DEVSHELL_PROJECT_ID` set to the project ID
- A valid Compute Engine zone in which to create the VM

## Before running

Review `script.sh` and replace its hard-coded project IDs, asset bucket, and zone references with values for your lab. The script creates an `e2-standard-2` VM and a firewall rule allowing HTTP from anywhere. It also installs packages and runs commands on that VM. These resources may incur charges; confirm project and network settings first.

## Run

From this directory in an authenticated Cloud Shell:

```bash
bash script.sh
```

The script prompts for the VM zone.
