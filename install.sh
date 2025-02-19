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
  local current_account
  current_account=$(gcloud config list account --format text | awk -F "core.account: " '{print $2}')
  local expected_value="wys1203@gmail.com"
  if [ "$current_account" != "$expected_value" ]; then
      echo "Running gcloud auth login..."
      gcloud auth login
      gcloud config set project wys1203
  else
      echo "  - Account: $expected_value"
  fi
}

# Download key by gcp_ssh_key_manager.sh
gcp_ssh_key_manager_download() {
  mkdir -p ~/.ssh
  echo "gcp_ssh_key_manager.sh Downloading..."
  curl -sSL "https://raw.githubusercontent.com/wys1203/my-gcloud-workspace/master/scripts/gcp_ssh_key_manager.sh" | bash -s download
}

# Clone the GitHub repository
clone_github_repo() {
  echo "Cloning GitHub repository..."
  mkdir -p $HOME/Personal_Data/src/github.com/wys1203
  git clone git@github.com:wys1203/init-dev-workspace $HOME/Personal_Data/src/github.com/wys1203/init-dev-workspace
}


# Instructions to execute this script from a GitHub URL:
# curl -sSL https://raw.githubusercontent.com/wys1203/my-gcloud-workspace/master/install.sh | bash

install_gcloud
gcloud_auth_login
gcp_ssh_key_manager_download
clone_github_repo
