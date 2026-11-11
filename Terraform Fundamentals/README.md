# Terraform Fundamentals

This lab installs Terraform, writes a Terraform configuration for a Compute Engine VM, initializes the working directory, and applies the configuration.

## Prerequisites

- A Google Cloud project with billing enabled and `gcloud` authenticated
- Terraform installed (the script attempts to install it on Debian/Ubuntu)
- Google Cloud provider credentials and permissions to create Compute Engine instances

## Before running

Review `script.sh` and replace its hard-coded project ID, zone, and resource settings with the intended lab values. The script modifies `~/.customize_environment`, installs software, creates `instance.tf`, and runs `terraform apply -auto-approve`, which creates resources without an interactive confirmation. The VM has an external IP and may incur charges. Do not run against a production project without reviewing the plan.

## Run

From this directory in the intended lab environment:

```bash
bash script.sh
```
