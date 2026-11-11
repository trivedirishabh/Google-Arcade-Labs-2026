# Compute Engine: Qwik Start - Windows

This lab creates a Windows Server 2022 Compute Engine VM, reads its serial-port output, and generates a Windows password for the `admin` account.

## Prerequisites

- A Google Cloud project with billing enabled and `gcloud` authenticated
- Permission to create Compute Engine instances and reset Windows passwords
- The `GOOGLE_CLOUD_PROJECT` environment variable set to the intended project
- A supported zone with sufficient quota for an `e2-medium` VM and a 50 GB boot disk

## Before running

Review `script.sh` and confirm the project and hard-coded zone (`us-west1-b`) are correct. Creating and running the Windows VM incurs charges. The script resets a password for the VM's `admin` account; handle the generated credentials securely.

## Run

Run from this directory in an authenticated shell:

```bash
bash script.sh
```
