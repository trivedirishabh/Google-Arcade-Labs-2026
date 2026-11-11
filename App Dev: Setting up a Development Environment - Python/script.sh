#!/bin/bash

echo -ne "Enter your zone: "
read ZONE                       

if [ -z "$ZONE" ]; then
  echo -e "No zone entered. Please try again."
  exit 1
fi

echo -e "You entered zone: $ZONE"

gcloud auth list

export ZONE                        # ← export so child processes see it
export REGION=${ZONE%-*}
export PROJECT_ID=$DEVSHELL_PROJECT_ID

gcloud config set compute/zone "$ZONE"
gcloud config set compute/region "$REGION"

gcloud compute instances create dev-instance \
  --project="$DEVSHELL_PROJECT_ID" \
  --zone="$ZONE" \
  --machine-type=e2-standard-2 \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --tags=http-server \
  --create-disk=auto-delete=yes,boot=yes,image=projects/debian-cloud/global/images/family/debian-12,mode=rw,size=10,type=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/diskTypes/pd-balanced \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --labels=goog-ec-src=vm_add-gcloud \
  --reservation-affinity=any

# Firewall rule may already exist — ignore that error
gcloud compute firewall-rules create allow-http \
  --action=ALLOW \
  --direction=INGRESS \
  --description="Allow HTTP traffic" \
  --rules=tcp:80 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=http-server 2>/dev/null || echo "Firewall rule already exists, skipping."

sleep 30   

cat > installation_script.sh <<EOF
sudo apt-get update
sudo apt-get install git -y
sudo apt-get install python3-setuptools python3-dev build-essential -y
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python3 get-pip.py --break-system-packages
python3 --version
pip3 --version
gcloud storage cp -r gs://qwiklabs-gcp-04-ee1564bd405e-assets/devenv .
cd devenv
sudo python3 server.py
sudo pip3 install -r requirements.txt --break-system-packages
python3 list-gce-instances.py qwiklabs-gcp-04-ee1564bd405e --zone=europe-west1-c

EOF

sleep 10

gcloud compute scp installation_script.sh dev-instance:/tmp \
  --project="$DEVSHELL_PROJECT_ID" \
  --zone="$ZONE" \
  --quiet

gcloud compute ssh dev-instance \
  --project="$DEVSHELL_PROJECT_ID" \
  --zone="$ZONE" \
  --quiet \
  --command='bash /tmp/installation_script.sh'

