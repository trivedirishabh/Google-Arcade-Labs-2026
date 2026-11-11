#!/bin/bash
gcloud compute instances create blue \
  --zone=us-east1-c \
  --machine-type=e2-medium \
  --image-family=debian-12 \
  --image-project=debian-cloud \
  --tags=web-server \
  --metadata=startup-script='#!/bin/bash
apt-get update
apt-get install -y nginx-light
echo "<h1>Welcome to the blue server!</h1>" > /var/www/html/index.nginx-debian.html'

gcloud compute instances create green \
  --zone=us-east1-c \
  --machine-type=e2-medium \
  --image-family=debian-12 \
  --image-project=debian-cloud \
  --metadata=startup-script='#!/bin/bash
apt-get update
apt-get install -y nginx-light
echo "<h1>Welcome to the green server!</h1>" > /var/www/html/index.nginx-debian.html'

gcloud compute firewall-rules create allow-http-web-server \
  --network=default \
  --direction=INGRESS \
  --priority=1000 \
  --action=ALLOW \
  --rules=tcp:80,icmp \
  --source-ranges=0.0.0.0/0 \
  --target-tags=web-server

gcloud compute instances create test-vm --machine-type=e2-micro --subnet=default --zone=us-east1-c

export ZONE=us-east1-c
export BLUE_EXTERNAL_IP=$(gcloud compute instances describe blue --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
export GREEN_EXTERNAL_IP=$(gcloud compute instances describe green --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
export BLUE_INTERNAL_IP=$(gcloud compute instances describe blue --zone=$ZONE --format='get(networkInterfaces[0].networkIP)')
export GREEN_INTERNAL_IP=$(gcloud compute instances describe green --zone=$ZONE --format='get(networkInterfaces[0].networkIP)')

gcloud projects add-iam-policy-binding qwiklabs-gcp-04-fd1ae2d5b736 \
  --member="serviceAccount:network-admin@qwiklabs-gcp-04-fd1ae2d5b736.iam.gserviceaccount.com" \
  --role="roles/compute.networkAdmin"

gcloud iam service-accounts keys create $HOME/credentials.json \
  --iam-account=network-admin@qwiklabs-gcp-04-fd1ae2d5b736.iam.gserviceaccount.com

gcloud auth activate-service-account --key-file=$HOME/credentials.json

gcloud compute firewall-rules delete allow-http-web-server --quiet

gcloud config set account student-03-dca1b8ffd81b@qwiklabs.net