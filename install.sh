#!/bin/bash

# Check the current operating system and install gcloud command
install_gcloud() {
  if command -v gcloud &> /dev/null; then
    echo "gcloud is already installed."
    return
  fi

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Installing gcloud for Linux..."
    sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates gnupg
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    sudo apt-get update && sudo apt-get install -y google-cloud-sdk
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Installing gcloud for macOS..."
    if ! command -v brew &> /dev/null; then
      echo "Homebrew not found. Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    echo "Installing gcloud for macOS..."
    brew install --cask google-cloud-sdk
  else
    echo "Unsupported OS type: $OSTYPE"
    exit 1
  fi
}

# Process gcloud auth login
gcloud_auth_login() {
  echo "Starting gcloud auth login..."
  gcloud auth login
}

# Download gcp_ssh_key_manager.sh
download_gcp_ssh_key_manager() {
  echo "Downloading gcp_ssh_key_manager.sh..."
  curl -O https://raw.githubusercontent.com/wys1203/my-gcloud-workspace/main/scripts/gcp_ssh_key_manager.sh
}

# Clone the GitHub repository
clone_github_repo() {
  ssh-keyscan github.com >> ~/.ssh/known_hosts
  echo "Cloning GitHub repository..."
  mkdir -p $HOME/go/src/github.com/wys1203
  git clone git@github.com:wys1203/init-dev-workspace $HOME/go/src/github.com/wys1203/init-dev-workspace
}

# Instructions to execute this script from a GitHub URL:
# curl -sSL https://raw.githubusercontent.com/wys1203/my-gcloud-workspace/main/install.sh | bash

install_gcloud
gcloud_auth_login
download_gcp_ssh_key_manager
clone_github_repo
