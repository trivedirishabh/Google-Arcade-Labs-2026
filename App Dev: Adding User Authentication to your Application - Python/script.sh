PROJECT_ID=$(gcloud config get project)
gcloud services enable identitytoolkit.googleapis.com

echo "Downloading starter code"
gcloud storage cp -r gs://qwiklabs-gcp-03-d8e0ffd75c58-assets/firebase .

cd ~/firebase/start

export REGION=us-central
sed -i "s/us-central/$REGION/g" prepare_environment.sh
sh ~/firebase/start/prepare_environment.sh
echo "Running application for Task1"
python run_server.py

