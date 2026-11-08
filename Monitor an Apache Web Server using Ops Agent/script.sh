export PROJECT_ID=$(gcloud config get-value project)

export PROJECT_ID=$DEVSHELL_PROJECT_ID

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

gcloud config set compute/zone $ZONE

gcloud compute instances create quickstart-vm --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --machine-type=e2-small --image-family=debian-12 --image-project=debian-cloud --tags=http-server,https-server && gcloud compute firewall-rules create default-allow-http --target-tags=http-server --allow tcp:80 --description="Allow HTTP traffic"
gcloud compute firewall-rules create default-allow-https --target-tags=https-server --allow tcp:443 --description="Allow HTTPS traffic"

cat > apache_installation.sh <<'EOF1'

sudo apt-get update && sudo apt-get install apache2 php7.0 -y

curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install


# Configures Ops Agent to collect telemetry from the app and restart Ops Agent.

set -e

# Create a back up of the existing file so existing configurations are not lost.
sudo cp /etc/google-cloud-ops-agent/config.yaml /etc/google-cloud-ops-agent/config.yaml.bak

# Configure the Ops Agent.
sudo tee /etc/google-cloud-ops-agent/config.yaml > /dev/null << EOF
metrics:
  receivers:
    apache:
      type: apache
  service:
    pipelines:
      apache:
        receivers:
          - apache
logging:
  receivers:
    apache_access:
      type: apache_access
    apache_error:
      type: apache_error
  service:
    pipelines:
      apache:
        receivers:
          - apache_access
          - apache_error
EOF

sudo service google-cloud-ops-agent restart
sleep 60

EOF1


gcloud compute scp apache_installation.sh quickstart-vm:/tmp --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet

gcloud compute ssh quickstart-vm --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet --command="bash /tmp/apache_installation.sh"


gcloud services enable monitoring.googleapis.com

gcloud beta monitoring channels create \
  --display-name="My Email Alerts" \
  --type=email \
  --channel-labels=email_address="student-03-4094c84de348@qwiklabs.net"

CHANNEL=$(gcloud beta monitoring channels list \
  --filter='displayName="My Email Alerts"' \
  --format='value(name)' | head -n 1)

echo $CHANNEL

cat > apache-alert.yaml <<EOF
displayName: "Apache traffic above threshold"
combiner: OR
enabled: true

notificationChannels:
- "$CHANNEL"

conditions:
- displayName: "Apache traffic exceeds 4000 bytes/sec"
  conditionThreshold:
    filter: 'resource.type="gce_instance" AND metric.type="workload.googleapis.com/apache.traffic"'
    comparison: COMPARISON_GT
    thresholdValue: 4000
    duration: 0s
    aggregations:
    - alignmentPeriod: 60s
      perSeriesAligner: ALIGN_RATE
    trigger:
      count: 1

alertStrategy:
  autoClose: 1800s
EOF


gcloud monitoring policies create \
  --policy-from-file=apache-alert.yaml