gcloud services enable cloudprofiler.googleapis.com

git clone https://github.com/GoogleCloudPlatform/golang-samples.git
cd golang-samples/profiler/shakesapp

go run . -version 1 -num_rounds 15

