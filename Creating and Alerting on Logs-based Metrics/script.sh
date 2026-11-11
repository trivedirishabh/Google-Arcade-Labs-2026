gcloud config set compute/zone europe-west4-b

export PROJECT_ID=$(gcloud info --format='value(config.project)')

gcloud container clusters create gmp-cluster --num-nodes=1 --zone europe-west4-b
set -e

EMAIL="student-00-1cdd87c1c7c9@qwiklabs.net"
CHANNEL_NAME="VM Stop Alert Email"

echo "Creating notification channel..."

# Reuse an existing channel or create a new one
CHANNEL_ID=$(gcloud beta monitoring channels list \
  --format="value(name,displayName)" |
  awk -F '\t' '$2 == "VM Stop Alert Email" {print $1; exit}')

if [ -z "$CHANNEL_ID" ]; then
  echo "ERROR: Notification channel not found."
  exit 1
fi

echo "Using notification channel: $CHANNEL_ID"

echo "Notification channel: $CHANNEL_ID"

# Generate alert policy configuration
cat > /tmp/stopped-vm-alert.json <<EOF
{
  "displayName": "stopped vm",
  "conditions": [
    {
      "displayName": "VM instance stopped",
      "conditionMatchedLog": {
        "filter": "resource.type=\"gce_instance\" AND protoPayload.methodName=\"v1.compute.instances.stop\""
      }
    }
  ],
  "combiner": "OR",
  "enabled": true,
  "notificationChannels": [
    "$CHANNEL_ID"
  ],
  "alertStrategy": {
    "notificationRateLimit": {
      "period": "300s"
    },
    "autoClose": "3600s"
  }
}
EOF

# Avoid duplicate policy creation
POLICY_ID=$(gcloud monitoring policies list \
  --format="value(name)" \
  --filter="displayName='stopped vm'")

if [ -n "$POLICY_ID" ]; then
  gcloud monitoring policies update "$POLICY_ID" \
    --policy-from-file=/tmp/stopped-vm-alert.json
else
  gcloud monitoring policies create \
    --policy-from-file=/tmp/stopped-vm-alert.json
fi

echo "Successfully configured stopped VM alert!"

gcloud artifacts repositories create docker-repo --repository-format=docker \
    --location=europe-west4 --description="Docker repository" \
    --project=qwiklabs-gcp-01-8c60e852ef3d

wget https://storage.googleapis.com/spls/gsp1024/flask_telemetry.zip
unzip flask_telemetry.zip
docker load -i flask_telemetry.tar

docker tag gcr.io/ops-demo-330920/flask_telemetry:61a2a7aabc7077ef474eb24f4b69faeab47deed9 \
europe-west4-docker.pkg.dev/qwiklabs-gcp-01-8c60e852ef3d/docker-repo/flask-telemetry:v1

docker push europe-west4-docker.pkg.dev/qwiklabs-gcp-01-8c60e852ef3d/docker-repo/flask-telemetry:v1

CLUSTER="gmp-cluster"
NAMESPACE="gmp-test"
IMAGE="europe-west4-docker.pkg.dev/qwiklabs-gcp-01-8c60e852ef3d/docker-repo/flask-telemetry:v1"

echo "Checking cluster status..."

while true; do
  STATUS=$(gcloud container clusters describe "$CLUSTER" \
    --format="value(status)" 2>/dev/null || true)

  if [ "$STATUS" = "RUNNING" ]; then
    echo "Cluster is RUNNING"
    break
  fi

  echo "Cluster status: $STATUS. Waiting 15 seconds..."
  sleep 15
done

echo "Authenticating cluster..."
gcloud container clusters get-credentials "$CLUSTER"

echo "Creating namespace..."
kubectl create namespace "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Downloading application..."
wget -q -O gmp_prom_setup.zip \
  https://storage.googleapis.com/spls/gsp1024/gmp_prom_setup.zip

unzip -oq gmp_prom_setup.zip
cd gmp_prom_setup

echo "Updating container image..."
sed -i.bak "s|<ARTIFACT REGISTRY IMAGE NAME>|$IMAGE|g" \
  flask_deployment.yaml

echo "Deploying application..."
kubectl -n "$NAMESPACE" apply -f flask_deployment.yaml
kubectl -n "$NAMESPACE" apply -f flask_service.yaml

echo "Waiting for deployment..."
kubectl -n "$NAMESPACE" rollout status deployment --timeout=180s

echo ""
echo "Application services:"
kubectl get services -n "$NAMESPACE"

echo ""
echo "Application pods:"
kubectl get pods -n "$NAMESPACE"

echo ""
echo "Task 4 deployment completed!"

METRIC_NAME="hello-app-error"

echo "Creating log-based metric: $METRIC_NAME"

# Check whether metric already exists
EXISTING=$(gcloud logging metrics list \
  --format="value(name)" \
  --filter="name=$METRIC_NAME")

if [ -n "$EXISTING" ]; then
  echo "Metric already exists. Updating..."
  gcloud logging metrics update "$METRIC_NAME" \
    --description="Counts errors from hello-app container" \
    --log-filter='severity=ERROR AND resource.labels.container_name="hello-app" AND textPayload:"ERROR: 404 Error page not found"'
else
  echo "Creating metric..."
  gcloud logging metrics create "$METRIC_NAME" \
    --description="Counts errors from hello-app container" \
    --log-filter='severity=ERROR AND resource.labels.container_name="hello-app" AND textPayload:"ERROR: 404 Error page not found"'
fi

echo ""
echo "Verifying metric..."
gcloud logging metrics describe "$METRIC_NAME"

echo ""
echo "Task 5 completed!"

METRIC_NAME="hello-app-error"
POLICY_NAME="log based metric alert"
CHANNEL_NAME="VM Stop Alert Email"

echo "Checking log-based metric..."
gcloud logging metrics describe "$METRIC_NAME" >/dev/null

echo "Discovering notification channel..."

CHANNEL_ID=$(gcloud beta monitoring channels list \
  --format="value(name,displayName)" |
  awk -F '\t' -v channel="$CHANNEL_NAME" '$2 == channel {print $1; exit}')

if [ -z "$CHANNEL_ID" ]; then
  echo "ERROR: Notification channel '$CHANNEL_NAME' not found."
  echo "Available notification channels:"
  gcloud beta monitoring channels list \
    --format="table(displayName,name)"
  exit 1
fi

echo "Found notification channel: $CHANNEL_ID"

cat > /tmp/metric-alert.json <<EOF
{
  "displayName": "$POLICY_NAME",
  "combiner": "OR",
  "enabled": true,
  "conditions": [
    {
      "displayName": "hello-app-error metric threshold",
      "conditionThreshold": {
        "filter": "resource.type=\"k8s_container\" AND metric.type=\"logging.googleapis.com/user/$METRIC_NAME\"",
        "comparison": "COMPARISON_GT",
        "thresholdValue": 0,
        "duration": "0s",
        "aggregations": [
          {
            "alignmentPeriod": "120s",
            "perSeriesAligner": "ALIGN_SUM"
          }
        ],
        "trigger": {
          "count": 1
        }
      }
    }
  ],
  "notificationChannels": ["$CHANNEL_ID"]
}
EOF

POLICY_ID=$(gcloud monitoring policies list \
  --format="value(name)" |
  awk -F/ '$NF != "" {print $0}' | head -n 0)

# Find existing policy by display name
POLICY_ID=$(gcloud monitoring policies list \
  --format="json" |
  python3 -c "import sys,json; print(next((p['name'] for p in json.load(sys.stdin) if p.get('displayName') == '$POLICY_NAME'), ''))")

if [ -n "$POLICY_ID" ]; then
  gcloud monitoring policies update "$POLICY_ID" \
    --policy-from-file=/tmp/metric-alert.json
else
  gcloud monitoring policies create \
    --policy-from-file=/tmp/metric-alert.json
fi

echo "Task 6 completed!"

echo "Retrieving application LoadBalancer IP..."

while true; do
  LB_IP=$(kubectl get services -n "$NAMESPACE" \
    -o jsonpath='{.items[*].status.loadBalancer.ingress[0].ip}')

  if [ -n "$LB_IP" ]; then
    break
  fi

  echo "LoadBalancer IP not assigned yet. Waiting..."
  sleep 5
done

echo "Application IP: $LB_IP"
echo "Generating 404 errors for 120 seconds..."

timeout 120 bash -c '
  while true; do
    curl -s -o /dev/null "http://'"$LB_IP"'/error"
    sleep $((RANDOM % 4))
  done
' || STATUS=$?

if [ "${STATUS:-0}" -ne 124 ]; then
  echo "Error generation command exited with status ${STATUS}."
  exit 1
fi

echo "Completed error generation."
