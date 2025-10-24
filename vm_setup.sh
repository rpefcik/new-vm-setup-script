#!/bin/bash

# This script automates the installation of Docker CE on Ubuntu,
# creates a docker group, adds the current user to it,
# configures credentials, and clones sample Git repositories.
# It prompts the user for confirmation before each major step.

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to ask the user if they want to proceed with a step
ask_to_proceed() {
    read -p "Do you want to $1? (y/n) " -n 1 -r
    echo # Move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0 # Yes
    else
        echo "Skipping this step."
        return 1 # No
    fi
}

echo "Starting Docker CE installation and configuration..."
echo "You will be prompted to confirm each step of the process."
echo ""

# 1. Update package lists and install prerequisites
if ask_to_proceed "update packages and install prerequisites"; then
    echo "--> Updating packages and installing prerequisites..."
    sudo apt-get update
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        git \
        software-properties-common
fi

# 2. Add Docker’s official GPG key
if ask_to_proceed "add Docker’s official GPG key"; then
    echo "--> Adding Docker's official GPG key..."
    # Note: apt-key is deprecated but used here as requested.
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
fi

# 3. Set up the stable repository for Ubuntu Focal (20.04)
if ask_to_proceed "set up the Docker repository"; then
    echo "--> Setting up the Docker repository for Ubuntu Focal..."
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
fi

# 4. Install Docker Engine
if ask_to_proceed "install Docker CE"; then
    echo "--> Installing Docker CE..."
    sudo apt-get update
    echo "--> Verifying docker-ce package availability..."
    apt-cache policy docker-ce
    sudo apt-get install -y docker-ce
fi

# 5. Check Docker Service Status
if ask_to_proceed "check the Docker service status"; then
    echo "--> Checking the status of the Docker service..."
    sudo systemctl status docker --no-pager
fi

# 6. Add the current user to the 'docker' group
if ask_to_proceed "add the current user to the 'docker' group"; then
    echo "--> Adding current user to the docker group..."
    sudo usermod -aG docker ${USER}
fi

# 7. Configure GitHub Credentials
if ask_to_proceed "configure GitHub credentials"; then
    echo "--> Configuring GitHub credentials..."
    read -p "Enter your GitHub username: " github_user
    read -p "Enter your GitHub email: " github_email
    echo "" # Add a newline

    # Create .gitconfig
    cat << EOF > ~/.gitconfig
[user]
    name = $github_user
    email = $github_email
[credential]
    helper = store
EOF

    # Create .git-credentials by pasting content
    echo "Please prepare your Git credential string."
    echo "The required format is: https://<username>:<personal_access_token>@github.com"
    read -p "Paste your full credential string now: " git_credentials_content
    echo "$git_credentials_content" > ~/.git-credentials

    # Set secure permissions for the credentials file
    chmod 600 ~/.git-credentials

    echo "GitHub credentials stored in ~/.gitconfig and ~/.git-credentials"
fi

# 8. Configure Docker Credentials
if ask_to_proceed "configure Docker credentials"; then
    echo "--> Configuring Docker credentials..."
    read -p "Enter your Docker Hub username: " docker_user
    read -sp "Enter your Docker Hub password or Access Token: " docker_pass
    echo "" # Add a newline after the hidden input

    # Create the .docker directory if it doesn't exist
    mkdir -p ~/.docker

    # Create the Docker config.json
    auth_string=$(echo -n "${docker_user}:${docker_pass}" | base64)
    cat << EOF > ~/.docker/config.json
{
  "auths": {
    "https://index.docker.io/v1/": {
      "auth": "$auth_string"
    }
  }
}
EOF
    echo "Docker credentials stored in ~/.docker/config.json"
fi

# 9. Clone sample Git repositories
if ask_to_proceed "clone Git repositories"; then
    echo "--> Cloning Git repositories..."
    CLONE_DIR=~/repos
    echo "Creating directory for repositories at $CLONE_DIR"
    mkdir -p $CLONE_DIR
    cd $CLONE_DIR

    echo "Cloning brightpick/brightpick..."
    git clone https://github.com/brightpick/brightpick.git

    echo "Cloning brightpick/brightpick-deployment..."
    git clone https://github.com/brightpick/brightpick-deployment.git

    echo "Cloning brightpick/ra-qa..."
    git clone https://github.com/brightpick/ra-qa.git

    echo "Repositories have been cloned into $CLONE_DIR"
    cd ~
fi

echo ""
echo "--------------------------------------------------"
echo "✅ Script finished."
echo "--------------------------------------------------"
echo "⚠️  IMPORTANT: If you added your user to the docker group, you must"
echo "log out and log back in OR run 'su - \${USER}' for the changes to take effect."
echo "--------------------------------------------------"
