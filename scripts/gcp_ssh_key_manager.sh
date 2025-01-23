#!/bin/bash

# Ensure Google Cloud SDK is installed and authenticated
# gcloud auth login

# Function to upload SSH key to GCP Secret Manager
upload_ssh_key() {
  local secret_name="ssh-key"
  local key_file="$HOME/.ssh/id_rsa"

  if [ ! -f "$key_file" ]; then
    echo "SSH key file not found: $key_file"
    exit 1
  fi

  # Create or update the secret
  gcloud secrets create "$secret_name" --data-file="$key_file" --replication-policy="automatic" || \
  gcloud secrets versions add "$secret_name" --data-file="$key_file"
}

# Function to download SSH key from GCP Secret Manager
download_ssh_key() {
  local secret_name="ssh-key"
  local key_file="$HOME/.ssh/id_rsa"

  # Access the secret and save it to the file
  gcloud secrets versions access latest --secret="$secret_name" > "$key_file"
  chmod 600 "$key_file"
}

# Main script execution
case "$1" in
  upload)
    upload_ssh_key
    ;;
  download)
    download_ssh_key
    ;;
  *)
    echo "Usage: $0 {upload|download}"
    exit 1
    ;;
esac
