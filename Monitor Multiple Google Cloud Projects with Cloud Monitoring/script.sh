
#!/bin/bash

echo "Provide PROJECT_ID1"
read -r PROJECT_ID1

echo "Provide PROJECT_ID2"
read -r PROJECT_ID2

# Set project variables
export PROJECT_ID="$PROJECT_ID2"

echo "Creating Virtual Machine in $PROJECT_ID2"

gcloud config set project "$PROJECT_ID2"

# Create VM only if it does not already exist
if ! gcloud compute instances describe instance2 \
  --zone=europe-west4-c \
  --project="$PROJECT_ID2" >/dev/null 2>&1; then

  gcloud compute instances create instance2 \
    --zone=europe-west4-c \
    --project="$PROJECT_ID2"
else
  echo "instance2 already exists. Skipping creation."
fi

# Add project to Monitoring Metrics Scope
if ! gcloud beta monitoring metrics-scopes describe \
  --project="$PROJECT_ID2" 2>/dev/null | grep -q "$PROJECT_ID1"; then

  gcloud beta monitoring metrics-scopes create "$PROJECT_ID1" \
    --project="$PROJECT_ID2"
else
  echo "Project already exists in Monitoring Metrics Scope."
fi
# Create DemoGroup only if it does not already exist
TOKEN=$(gcloud auth print-access-token)

RESPONSE=$(curl -s \
  -H "Authorization: Bearer $TOKEN" \
  "https://monitoring.googleapis.com/v3/projects/$PROJECT_ID2/groups")

GROUP_ID=$(echo "$RESPONSE" | jq -r \
  '(.group // [])[] | select(.displayName=="DemoGroup") | .name | split("/")[-1]' \
  | head -n 1)

if [ -z "$GROUP_ID" ]; then
  RESPONSE=$(curl -s -X POST \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    "https://monitoring.googleapis.com/v3/projects/$PROJECT_ID2/groups" \
    -d '{
      "displayName": "DemoGroup",
      "filter": "resource.metadata.name = has_substring(\"instance\")"
    }')

  GROUP_ID=$(echo "$RESPONSE" | jq -r '.name | split("/")[-1]')
fi

if [ -z "$GROUP_ID" ] || [ "$GROUP_ID" = "null" ]; then
  echo "ERROR: Could not retrieve or create DemoGroup."
  echo "$RESPONSE"
  exit 1
fi

echo "DemoGroup ID: $GROUP_ID"

# Create uptime check
gcloud monitoring uptime create "DemoGroup uptime check" \
  --project="$PROJECT_ID2" \
  --group-id="$GROUP_ID" \
  --group-type=gce-instance \
  --protocol=tcp \
  --port=22 \
  --period=1

# Create alert policy YAML
cat > uptime-policy.yaml <<'EOF'
displayName: Uptime Check Policy
combiner: OR
conditions:
  - displayName: VM Instance-Check passed
    conditionAbsent:
      filter: 'metric.type="monitoring.googleapis.com/uptime_check/check_passed" AND metric.label.check_id="demogroup-uptime-check-id" AND resource.type="gce_instance"'
      duration: 300s
notificationChannels: []
enabled: true
EOF

# Create alert policy
gcloud monitoring policies create \
  --project="$PROJECT_ID2" \
  --policy-from-file=uptime-policy.yaml

# Create dashboard YAML
cat > dashboard.yaml <<'EOF'
displayName: DemoGroup Dashboard
dashboardFilters: []
gridLayout:
  columns: 2
  widgets:
    - title: VM Instance Uptime
      xyChart:
        dataSets:
          - timeSeriesQuery:
              timeSeriesFilter:
                filter: 'metric.type="compute.googleapis.com/instance/uptime" AND resource.type="gce_instance"'
                aggregation:
                  alignmentPeriod: 60s
                  perSeriesAligner: ALIGN_MEAN
            plotType: LINE
        timeshiftDuration: 0s
        yAxis:
          label: Uptime
          scale: LINEAR
EOF

# Create dashboard
gcloud monitoring dashboards create \
  --project="$PROJECT_ID2" \
  --config-from-file=dashboard.yaml
