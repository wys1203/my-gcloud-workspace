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

update_know_hosts_for_github() {
  local host="github.com"
  if ! ssh-keygen -F "$host" > /dev/null; then
    echo "$host not found in known_hosts. Adding it now..."
    ssh-keyscan github.com >> ~/.ssh/known_hosts

    if [ $? -eq 0]; then 
      echo "$host has been added to known_hosts."
    else 
      echo "Failed to add $host to known_hosts. Please check your network connection or ssh-keyscan command."
    fi
  else
    echo "$host is already in known_hosts."
  fi
}

# Main script execution
case "$1" in
  upload)
    upload_ssh_key
    ;;
  download)
    download_ssh_key
    update_know_hosts_for_github
    ;;
  *)
    echo "Usage: $0 {upload|download}"
    exit 1
    ;;
esac
