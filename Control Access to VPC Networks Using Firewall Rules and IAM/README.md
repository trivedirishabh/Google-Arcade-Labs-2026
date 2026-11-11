# Control Access to VPC Networks Using Firewall Rules and IAM

This lab creates Compute Engine VMs and a firewall rule, then demonstrates changing firewall and IAM access, including authenticating as a service account.

## Prerequisites

- A Google Cloud project with billing enabled and `gcloud` authenticated
- Permission to create Compute Engine instances and firewall rules, change project IAM policies, and create service-account keys

## Before running

Review `script.sh` and replace the hard-coded project ID, service-account email, and account values with the intended lab resources. The script grants the Compute Network Admin role, creates a service-account key at `$HOME/credentials.json`, activates that identity, deletes a firewall rule, and changes the active `gcloud` account. Protect and remove the generated key securely when no longer needed. Do not run these commands against a production project.

The script also creates VMs and a firewall rule allowing HTTP and ICMP from any IP address. These resources may incur charges and expose services publicly.

## Run

Run only in the intended lab project after reviewing and updating the script:

```bash
bash script.sh
```
