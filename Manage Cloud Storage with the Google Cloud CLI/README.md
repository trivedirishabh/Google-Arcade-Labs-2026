# Manage Cloud Storage with the Google Cloud CLI

This lab uses `gcloud storage` commands to create a bucket, upload and copy an image, change object access, and then remove the object.

## Prerequisites

- A Google Cloud project with billing enabled and `gcloud` authenticated
- Permission to create Cloud Storage buckets and manage object access
- A globally unique bucket name available in the selected project

## Before running

Review `script.sh`. It uses the active `gcloud` project, prompts for a region, downloads an image, and temporarily grants `allUsers` read access to an object. That object is publicly accessible until the script reaches the removal command. The script pauses for Enter before removing public access and deleting the object; do not leave it paused while the object is public.

## Run

Run from this directory in an authenticated shell:

```bash
bash script.sh
```
