# Create and Configure Multiple VPC Networks

This lab creates custom VPC networks, regional subnets, firewall rules, and Compute Engine VMs, including a VM with multiple network interfaces.

## Prerequisites

- A Google Cloud project with billing enabled and `gcloud` authenticated
- Permission to create VPC networks, subnets, firewall rules, and Compute Engine instances
- The `mynetwork` VPC and subnet referenced by the final VM command, if they are not created separately as part of the lab

## Before running

Review `script.sh` for the hard-coded regions, zones, subnet ranges, and network names. The firewall rules allow ICMP, SSH, and RDP from `0.0.0.0/0`; restrict these source ranges to trusted addresses where possible. The script creates several VM resources that may incur charges.

## Run

Run from this directory in an authenticated shell after confirming the project and prerequisites:

```bash
bash script.sh
```
